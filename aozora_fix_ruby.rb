#!/usr/bin/env ruby

module AozoraFixRuby
  ################################
  def fix_ruby( line )
    result = []
    
    ## �O������
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
      
      if /�b/s =~ elem
        result << elem
      else
        result << parse_ruby( elem )
      end
    }
    
    return result.join("")
  end

  ################################
  def escape_gaiji( str )

    unless /�s.+?�t/s =~ str
      return str
    end

=begin
    �m�����ŁA�v���m����̎��_�A�ʋ�_�ԍ�1-2-22�A33-3�n�s�܂��܂��t�͂������
               1 2                                   5
    ��
    �m�����ŁA�v���s�܂��܂��t�m����̎��_�A�ʋ�_�ԍ�1-2-22�A33-3�n�͂������
               1 5          2
=end
      
    str.sub!( /(��)(�m��.+?�n)((?:<img[^>]+>|[��-꤁X��]|�m��[^�n]+�n)*?)(�s.+?�t)/, '\1\3\4\5\2' )
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
    if /�s.+?�t/ =~ line
      temp = line.gsub!( "�t", "�t#{__sep__}" )
      return temp.split( __sep__ )
    else ## ���r�Ȃ�
      return [line]
    end
  end
    
  
  ################################
  def is_kanji?( str )
    print str if $DEBUG
    
    if /[��-꤁X��A-Za-z]/s =~ str
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
      if c == "�s"
        result.unshift c
        rubyed = true
      else
        if rubyed
          if is_kanji?( c )
            result.unshift c
          else
            result.unshift "�b"
            result.unshift c
            rubyed = false
          end
        else
          result.unshift c
        end
      end
      print "#{rubyed}  " if $DEBUG
    }
    
    # �s��
    if rubyed
      result.unshift "�b"
    end
    
    return result
  end
  
  module_function :fix_ruby
end


if $0 == __FILE__
  
  include AozoraFixRuby

  Header_sep = '-------------------------------------------------------'
  
  
  # ���̓t�@�C��
  textfile = ARGV[0]
  # �o�̓t�@�C��
  outfile = ARGV[1]
  
  ##  $log_in_output << "��������: #{Time.now}"
    
  src = File.read( textfile )
  header1, header2, temp = src.split( Header_sep )
  
  body, footer = temp.split( /^��{�F/s )
  
  #body.strip!
  footer = '��{�F' + footer
  
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
