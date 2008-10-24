require 'yahoofinance'
require 'date'

class StockController < ApplicationController
  layout 'standard', :except => ['chart_data', 'chart_settings']
  before_filter :login_required, :except => ['list', 'show', 'chart_data', 'chart_settings']

  @@default_days = 500
  @@default_chart_days = 90

  def list
    @stocks = Stock.find(:all, :order => 'ticker')
    #stock_list = @stocks.collect {|s| s.ticker}
    #@yah = YahooFinance::get_standard_quotes(stock_list)
  end

  def show
    @stock = Stock.find(params[:id])
    @yahoo_stock = YahooFinance::get_standard_quotes(@stock.ticker)
#     days = (params[:days].to_i > 0 ? params[:days].to_i : @@default_chart_days)
#     quotes = Stock.find(params[:id]).quotes.all(:limit => days + 30, :order => 'date DESC').reverse
#     quotes_only = quotes.map {|q| q.adj_close}
    
#     finance = Finance.new
#     ema_20 = finance.ema(quotes_only, 20)
#     ema_5  = finance.ema(quotes_only, 5)

#     (macd_26_12, macd_9, divergences) = finance.macd(quotes_only)
#     macd_26_12 = macd_26_12[30, macd_26_12.length]
#     macd_9     = macd_9[30, macd_9.length]
#     divergences = divergences[30, divergences.length]

#     # remove extra data from beginning - that was used only for calculations
#     quotes_only = quotes_only[30, quotes_only.length]
#     ema_20 = ema_20[30, ema_20.length]
#     ema_5  = ema_5[30, ema_5.length]
    
#     chart_max = (quotes_only.max * 1.1).round
#     # close price position
#     stock_close = (quotes_only.last / chart_max) * 100
#     stock_max   = (quotes_only.max  / chart_max) * 100

  end

  def chart_data
    @quotes = Stock.find(params[:id]).quotes.all(:limit => 1000, :order => 'date DESC')
  end

  def chart_settings
    @stock = Stock.find(params[:id])
  end

  def new
    @stock = Stock.new
  end

  def create
    @stock = Stock.new(params[:stock])
    days = params[:days].to_i
    if @stock.save
      if !days or days.to_i <= 0
        days = @@default_days
      end
      import(@stock.id, days)
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @stock = Stock.find(params[:id])
  end

  def delete
    Stock.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  # add new quotes since last import
  def update_all
    Stock.all.each do |stock|
      quote = stock.quotes.find(:first, :order => 'date DESC')
      days = Date.today - quote.date - 1
      puts "STOCK: #{stock.ticker}"
      puts "LAST DATE: #{quote.date}"
      puts "DAYS: #{days}"
      puts
      if days >= 1
        import(stock.id, days)
      end
    end
    redirect_to :action => 'list'
  end

  def ema
    finance = Finance.new
    days = params[:days].to_i
    quotes = Stock.find(params[:id]).quotes.all(:order => 'date DESC', :limit => days + 10).reverse.map {|q| q.adj_close}
    emas = finance.ema(quotes, days)
    p emas
    redirect_to :action => 'list'
  end

  def macd
    finance = Finance.new
    quotes = Stock.find(params[:id]).quotes.all(:order => 'date DESC', :limit => 100).reverse.map {|q| q.adj_close}
    macd = finance.macd(quotes)
    redirect_to :action => 'list'
  end

  def rsi
    finance = Finance.new
    quotes = Stock.find(params[:id]).quotes.all(:order => 'date DESC', :limit => 300).reverse.map {|q| q.adj_close}
    rsi = finance.rsi(quotes)
    redirect_to :action => 'list'    
  end


  #
  # Private functions
  # 
  
  private
  
  # Import last x days of stock data from Y! Finance
  def import(stock_id, days)
    @stock = Stock.find(stock_id)
    
    day_counter = 0
    YahooFinance::get_HistoricalQuotes_days(@stock.ticker, days) do |hq|
      q = Quote.new
      q.date = Date.parse(hq.date)
      q.stock_id = stock_id
      q.open = hq.open
      q.high = hq.high
      q.low  = hq.low
      q.close = hq.close
      q.volume = hq.volume
      q.adj_close = hq.adjClose
      q.save
      day_counter += 1
    end
    return day_counter
  end

end
