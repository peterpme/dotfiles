local menubar = hs.menubar.new()
local menuData = {}
local urlApi = "https://api.coingecko.com/api/v3/simple/price?ids=solana,bitcoin,ethereum,helium&vs_currencies=usd"

function getTokenPrices()
	hs.http.doAsyncRequest(urlApi, "GET", nil, nil, function(code, body)
		if code ~= 200 then
			print("get token prices error:" .. code)
			return
		end

		menuData = {}

		rawjson = hs.json.decode(body)
		table.insert(menuData, { title = "SOL $" .. rawjson.solana.usd })
		table.insert(menuData, { title = "ETH $" .. rawjson.ethereum.usd })
		table.insert(menuData, { title = "HNT $" .. rawjson.helium.usd })
		table.insert(menuData, {
			title = "Refresh",
			fn = function()
				getTokenPrices()
			end,
		})

		menubar:setTitle("💰")
		menubar:setMenu(menuData)
	end)
end

menubar:setTitle("⌛")
menubar:setTooltip("Crypto Prices")
getTokenPrices()
hs.timer.doEvery(180, getTokenPrices)
