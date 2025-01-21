const std = @import("std");
const zap = @import("zap");
const myzql = @import("myzql");
const result = myzql.result;
const QueryResultRows = result.QueryResultRows;
const TextResultRow = result.TextResultRow;
const ResultSet = result.ResultSet;

pub fn main() !void {
    var listener = zap.HttpListener.init(.{
        .port = 3000,
        .on_request = on_request,
        .log = true,
    });
    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:3000\n", .{});

    // start worker threads
    zap.start(.{
        .threads = 2,
        .workers = 2,
    });
}

fn on_request(r: zap.Request) void {
    if (r.path) |the_path| {
        std.debug.print("PATH: {s}\n", .{the_path});
    }
    if (r.query) |the_query| {
        std.debug.print("QUERY: {s}\n", .{the_query});
    }

    on_request_log_err(r) catch |err| {
        std.debug.print("on_request error: {any}\n", .{err});
    };
}

fn on_request_log_err(r: zap.Request) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var mysql_conn = try myzql.conn.Conn.init(allocator, &.{
        .username = "root",
        .address = std.net.Address.initIp4(.{ 127, 0, 0, 1 }, 3306),
        .password = "password",
    });
    defer mysql_conn.deinit();
    var query_res: QueryResultRows(TextResultRow) = try mysql_conn.queryRows(
        \\ SELECT "hello from mysql server"
    );
    var row: ResultSet(TextResultRow) = try query_res.expect(.rows);

    // put all result into a table
    const rows_data = try row.tableTexts(allocator);
    defer rows_data.deinit(allocator);

    // write result in readable string
    const rows_str = try std.fmt.allocPrint(
        allocator,
        "mysql: [{?s}]",
        .{rows_data.table[0][0]}, // get first row, first column
    );
    defer allocator.free(rows_str);

    try r.sendBody(rows_str);
}
