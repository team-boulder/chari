application =
{
	showRuntimeErrors = true,
    content =
    {
        graphicsCompatibility = 1,
        width = 640,
        height = 1136,--(640/display.pixelWidth) * display.pixelHeight,
        scale = "letterbox",
        fps = 60,
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
		},
		--]]
	},
    notification = 
    {
        google =
        {
            projectNumber = "784187625685"
        },
    },
	license =
	{
		google =
		{
			key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmI7LRYzjw99Dk6rrCmFYHvK648yAoShnqVQVF2TYKqee0A747IflzyUKkm6NZzjYzVMjL+4a3MW9Xzm9hwYYnPptZLDAG9DSZiwZHNfkDIVzEpcoVYlBp5c+WZmVqbKVBmMtgWpcR76D4QiThuy15xpkkbm4XYom3MkhEu8Tv25+kuJ18nsnLiA8qs/IvXLqwqBj0SER/4kRE/NR/PlIPAn/KhyQRBA+c0pffM5FSpis7nq0xPU67LawXGQwMdG/+NFJdMwJFZDJVWvGArogW3ajDTx5V4pS0e45bhOqC0txGqwRMfxKrlGzULjWNy0to9MgwftrR5B3KAm/g84YPQIDAQAB",
			-- This is optional, it can be strict or serverManaged(default).
			-- stric WILL NOT cache the server response so if there is no network access then it will always return false.
			-- serverManaged WILL cache the server response so if there is no network access it can use the cached response.
			policy = "serverManaged",
		},
	},
	notification =
	{
		iphone =
		{
			types =
			{
				"badge", "sound", "alert", "newsstand"
			}
		}
	},    
}
