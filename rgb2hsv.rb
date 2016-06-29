require 'pry'

class Color
  attr_accessor :name, :code

  def initialize(color_code, name = nil)
    @name = name
    @code = @rgb = color_code
    rgb
    r
    g
    b
    @max = [@r, @g, @b].max
    @min = [@r, @g, @b].min
  end

  def rgb
    @rgb = @rgb.delete("#").downcase
    if @rgb.size != 6
      STDERR.puts "[ERROR][#{self.class.name}.rgb] @rgb's length is not 6."
      exit 1
    end
    @rgb
  end

  def code
    "#" + rgb
  end

  def r
    @r = @rgb[0..1]
    @r = @r.to_i(16).to_f
  end

  def g
    @g = @rgb[2..3]
    @g = @g.to_i(16).to_f
  end

  def b
    @b = @rgb[4..5]
    @b = @b.to_i(16).to_f
  end

  def hue
    if @r == @g && @r == @b
      @h = 0
    elsif @max == @r
      @h = 60 * ((@g - @b) / (@max - @min))
    elsif @max == @g
      @h = 60 * ((@b - @r) / (@max - @min)) + 120
    elsif @max == @b
      @h = 60 * ((@r - @g) / (@max - @min)) + 240
    end
    @h += 360 if @h.negative?
    @h.to_i * 100 / 360
  end

  def saturation
    if @max == 0
      @s = 0
    else
      @s = 100 * (@max - @min) / @max
    end
    @s.to_i
  end

  def value
    @v = 100 * @max / 255
    @v.to_i
  end

  def hue_n11n
    hue / 100.0
  end

  def saturation_n11n
    saturation / 100.0
  end

  def value_n11n
    value / 100.0
  end

  def approx_color
    arr = []

    COLORS.each do |color2|
      arr << { diff: color_difference(self, color2), approx_color: { name: color2.name, rgb: "#" + color2.rgb } }
    end

    approx_color = arr.min_by { |color| color[:diff] }[:approx_color]
    @approx_color = Color.new(approx_color[:rgb], approx_color[:name])
  end
end

require './color_code_main'
MAX_DIFF = Math.sqrt(3)

def color_difference(src, dst)
  # HSV表色系でのユークリッド距離による色差の計算
  d_hue = src.hue_n11n - dst.hue_n11n
  d_saturation = src.saturation_n11n - dst.saturation_n11n
  d_value = src.value_n11n - dst.value_n11n
  Math.sqrt(d_hue * d_hue + d_saturation * d_saturation + d_value * d_value) / MAX_DIFF
end

class ExactColor
  def initialize(color1)
    arr = []

    COLORS.each do |color2|
      arr << { diff: color_difference(color1, color2), exact_color: { name: color2.name, rgb: "#" + color2.rgb } }
    end

    exact_color = arr.max_by { |color| color[:diff] }[:exact_color]
    @exact_color = Color.new(exact_color[:rgb], exact_color[:name])
  end

  def name
    @exact_color[:name]
  end

  def rgb
    @exact_color[:rgb]
  end
end

# exact_color(white)
# approx_color(white)
