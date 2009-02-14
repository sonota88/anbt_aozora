#!/usr/bin/env ruby

module AozoraFixRuby
  ################################
  def fix_ruby( line )
    result = []
    
    ## 外字処理
    line = escape_gaiji( line )
    
    fragments = split_by_ruby( line )
    if $DEBUG
      puts '***********************'
      puts fragments
      puts '***********************'
    end
    
    fragments.each{|elem|
       puts "=" * 32 if $DEBUG
       puts "elem: #{elem}" if $DEBUG
      
      if /｜/s =~ elem
        result << elem
      else
        result << parse_ruby( elem )
      end
    }
    
    return result.join("")
  end

  ################################
  def escape_gaiji( str )

    unless /《.+?》/s =~ str
      return str
    end

=begin
    確実さで、益※［＃二の字点、面区点番号1-2-22、33-3］《ますます》はっきりと
               1 2                                   5
    ↓
    確実さで、益※《ますます》［＃二の字点、面区点番号1-2-22、33-3］はっきりと
               1 5          2
=end
      
    str.sub!( /(※)(［＃.+?］)((?:<img[^>]+>|[亜-熙々※]|［＃[^］]+］)*?)(《.+?》)/, '\1\3\4\5\2' )
    #             1   2          34                                        5       67
    if $DEBUG
      puts "1: #{$1} kome"
      puts "2: #{$2} gaiji"
      puts "3: #{$3} img"
      puts "4: #{$4} img"
      puts "5: #{$5} ruby"
    end
    
    return str
  end
  
    
  ################################
  def split_by_ruby( line )
    __sep__ = '<gre2ia5fhu8rahuewaio9hfuewiao8ghureihgur9eskjhgur3ke1ahfueriahjrkds>'
    if /《.+?》/ =~ line
      temp = line.gsub!( "》", "》#{__sep__}" )
      return temp.split( __sep__ )
    else ## ルビなし
      return [line]
    end
  end
    
  
  ################################
  def is_kanji?( str )
    print str if $DEBUG
    
    if /[亜-熙々※A-Za-z]/s =~ str
      return true
    else
      return false
    end
  end
  
  ################################
  def parse_ruby( str )
    rubyed = false
    result = []
    
    str.split(//s).reverse.each{|c|
      print "#{rubyed}:#{c}:" if $DEBUG
      if c == "《"
        result.unshift c
        rubyed = true
      else
        if rubyed
          if is_kanji?( c )
            result.unshift c
          else
            result.unshift "｜"
            result.unshift c
            rubyed = false
          end
        else
          result.unshift c
        end
      end
      print "#{rubyed}  " if $DEBUG
    }
    
    # 行頭
    if rubyed
      result.unshift "｜"
    end
    
    return result
  end
  
  module_function :fix_ruby
end


if $0 == __FILE__
  
  include AozoraFixRuby

  Header_sep = '-------------------------------------------------------'
  
  
  # 入力ファイル
  textfile = ARGV[0]
  # 出力ファイル
  outfile = ARGV[1]
  
  ##  $log_in_output << "処理日時: #{Time.now}"
    
  src = File.read( textfile )
  header1, header2, temp = src.split( Header_sep )
  
  body, footer = temp.split( /^底本：/s )
  
  #body.strip!
  footer = '底本：' + footer
  
  body_fixed = []
  body.split( "\n" ).each{|line|
    body_fixed << AozoraFixRuby.fix_ruby( line )
  }
  
  fout = open( outfile, 'w' )
  fout.print header1, Header_sep, header2, Header_sep
  fout.print body_fixed.join("\n")
  fout.print footer
  fout.close
end
