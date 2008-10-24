class Finance
  @@default_days = 500

  def macd(quotes)
    ema_26 = ema(quotes, 26)
    ema_12 = ema(quotes, 12)

    # set first 27 elements in EMA(12) to 0
    ema_12[0, 27] = ema_12[0, 27].map {|e| e = 0}

    ema_26_12 = []
    quotes.each_with_index do |quote, index|
      ema_26_12[index] = sprintf("%.02f", ema_12[index] - ema_26[index]).to_f
    end

    macd_ema_9 = ema(ema_26_12, 9)

    divergences = []
    ema_26_12.each_with_index do |ema, index|
      divergences[index] = ema - macd_ema_9[index]
    end

    [ema_26_12, macd_ema_9, divergences]
  end

  # calculate EMA
  def ema(quotes, days)
    ema_results = []
    adj_closes = quotes[1, days]
    sma = quotes[1, days].inject {|sum, quote| sum + quote } / days
    ema_prev = sma
    multiplier = 2 / (days.to_f + 1)

    quotes.each_with_index do |quote, index|
      if index > days
        ema = sprintf("%.02f", ((quote - ema_prev) * multiplier) + ema_prev).to_f
        ema_results.push(ema)
        ema_prev = ema
      else
        ema_results.push(0)
      end
    end
    ema_results
  end

  # Wilder RSI
  def rsi(quotes)
    period = 14
    calc_days = 100

    rsi_results = []
    highs = lows = 0
    quotes[1,calc_days].each_with_index do |q, index|
      if q > quotes[index - 1]
        highs += (quotes[index - 1] - q).abs
      else
        lows += (quotes[index - 1] - q).abs
      end
    end

    avg_gain = prev_gain = highs / period
    avg_loss = prev_loss = lows  / period
    first_rs = avg_gain / avg_loss
    first_rsi = 100 - (100 / (1 + first_rs))

    quotes.each_with_index do |quote, index|
      if index > calc_days
        curr_gain = (quote > quotes[index - 1] ? quote - quotes[index - 1] : 0)
        curr_loss = (quote < quotes[index - 1] ? quotes[index - 1] - quote : 0)
        avg_gain = ((prev_gain * (period - 1)) + curr_gain) / period
        avg_loss = ((prev_loss * (period - 1)) + curr_loss) / period

        if avg_loss == 0
          rsi = 100
        else
          rs = avg_gain / avg_loss
          rsi = 100 - (100 / (1 + rs))
        end

        prev_gain = avg_gain
        prev_loss = avg_loss

        rsi_results[index] = sprintf("%.02f", rsi)
      elsif (index == calc_days)
        rsi_results[index] = sprintf("%.02f", first_rsi)
      else
        rsi_results[index] = 0
      end
    end
    rsi_results
  end

end
