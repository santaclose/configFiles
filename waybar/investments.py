import os
import re
import json
import requests

JSON_FILE_NAME = "investments.json"

def get_investments_object():
	if not os.path.exists(JSON_FILE_NAME):
		return None
	with open(JSON_FILE_NAME, 'r') as file:
		return json.loads(file.read())

def getCurrentCurrencyPrices(currencyList):
	coinRequestUrl = f"https://api.coingecko.com/api/v3/simple/price?ids={','.join(currencyList)}&vs_currencies=usd"
	coinRequestResponse = requests.get(coinRequestUrl).json()
	return {x: coinRequestResponse[x]['usd'] for x in currencyList}

def getCurrentStockPrices(stockList):
	stockRequestUrl = f"https://terminal-stocks.dev/{','.join(stockList)}"
	stockRequestResponse = requests.get(stockRequestUrl).text
	prices = re.findall(
		r'\x1b\[36m\$([\d,]+(?:\.\d{2})?)\x1b\[39m',
		stockRequestResponse
	)
	return {stockList[i]: float(prices[i]) for i in range(len(stockList))}

def computePerAssetInfo(assetList, assetType, obj, currentAssetPrices):
	perAssetInfo = {}
	for x in obj:
		if assetType not in x.keys():
			continue

		if x[assetType] not in perAssetInfo.keys():
			perAssetInfo[x[assetType]] = { "totalUnits": 0.0, "totalValue": 0.0, "gain": [] }

		if x['type'] == 'buy':
			perAssetInfo[x[assetType]]["totalValue"] += x['valueUSD']
			perAssetInfo[x[assetType]]["totalUnits"] += x['valueUSD'] / x['price']
			continue
		if x['type'] == 'sell':
			totalValue = perAssetInfo[x[assetType]]["totalValue"]
			totalUnits = perAssetInfo[x[assetType]]["totalUnits"]

			valueSold = x['valueUSD']
			unitsSold = x['valueUSD'] / x['price']
			valuePerUnitSoFar = totalValue / totalUnits
			previousUnitsSoldValue = valuePerUnitSoFar * unitsSold
			gain = valueSold - previousUnitsSoldValue
			totalUnits -= unitsSold
			totalValue = totalUnits * valuePerUnitSoFar

			perAssetInfo[x[assetType]]["totalValue"] = totalValue
			perAssetInfo[x[assetType]]["totalUnits"] = totalUnits
			perAssetInfo[x[assetType]]["gain"].append(gain)
	return perAssetInfo

currencyNameMap = {"bitcoin": "BTC", "cardano": "ADA", "nano": "XNO"}

def query():
	obj = get_investments_object()
	if obj is None:
		return

	stockList = list(set([x["stock"] for x in obj if "stock" in x.keys()]))
	currencyList = list(set([x["currency"] for x in obj if "currency" in x.keys()]))

	currencyPrices = getCurrentCurrencyPrices(currencyList)
	stockPrices = getCurrentStockPrices(stockList)

	perCurrencyInfo = computePerAssetInfo(currencyList, 'currency', obj, currencyPrices)
	perStockInfo = computePerAssetInfo(stockList, 'stock', obj, stockPrices)

	outputList = []
	for currency in currencyList:
		info = perCurrencyInfo[currency]
		gainString = f" ({','.join([str(x) for x in info['gain']])})" if len(info['gain']) > 0 else ""
		statusString = f" ({info['totalUnits'] * currencyPrices[currency]:.2f}/{info['totalValue']})" if info['totalUnits'] > 0 and info['totalValue'] > 0 else ""
		outputList.append(f"{currencyNameMap[currency]}: {currencyPrices[currency]}{gainString}{statusString}")
	for stock in stockList:
		info = perStockInfo[stock]
		gainString = f" ({','.join([str(x) for x in info['gain']])})" if len(info['gain']) > 0 else ""
		statusString = f" ({info['totalUnits'] * stockPrices[stock]:.2f}/{info['totalValue']})" if info['totalUnits'] > 0 and info['totalValue'] > 0 else ""
		outputList.append(f"{stock}: {stockPrices[stock]}{gainString}{statusString}")

	print("   ".join(outputList))

if __name__ == "__main__":
	query()