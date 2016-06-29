require 'RMagick'
require './rgb2hsv'

class RmagickCompileColor
  def initialize(img_file_name)
    @img = Magick::Image.read(img_file_name).first

    @px_x = @img.columns
    @px_y = @img.rows
    @px_total = @px_x * @px_y
  end

  def compile
    begin
      img_depth = @img.depth

      hist = @img.color_histogram.inject({}) do |hash, key_val|
        color = key_val[0].to_color(Magick::AllCompliance, false, img_depth, true)
        hash[color] ||= 0
        hash[color] += key_val[1]
        hash
      end

      @hist = hist.sort{ |a, b| b[1] <=> a[1] }
    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.compile] #{e}"
      exit 1
    end
  end

  def display
    begin
      rates = {}
      @hist.each do |color, count|
        rate = (count / @px_total.to_f) * 100
        color = Color.new(color)
        approx_color_name = color.approx_color.name
        rates[approx_color_name] ||= 0
        rates[approx_color_name] += rate
      end

      rates.select { |k, v| v > 1 }.sort { |a, b| b[1] <=> a[1] }.each do |rate|
        puts rate[0]
      end

    rescue => e
      STDERR.puts "[ERROR][#{self.class.name}.display] #{e}"
      exit 1
    end
  end
end

obj_main = RmagickCompileColor.new("http://res.cloudinary.com/hyohxi4rz/image/upload/c_fit,h_100,w_100/v1467475726/dnczqiejx1psqtzoh1yb.jpg")
obj_main.compile
obj_main.display
