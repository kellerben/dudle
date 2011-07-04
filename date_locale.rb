# coding: utf-8
#Make a 'localization' for Date, DateTime and Time.
#
#This is not using locale, but if you use locale, it is detected and locale sensitive.
#
#The output is in iso-8859-1, other encodings can be set with Date_locale.set_target_encoding.
#


require 'iconv'
require 'date'

#
#Adaption for a localized Date-class
#
#Solution based on discussion at ruby-forum.de 
#-http://forum.ruby-portal.de/viewtopic.php?f=1&t=10527&start=0
#
module Date_locale

  #Constant/Hash with the supported languages.
  #
  #Initial definitions are taken from localization_simplified.
  #
  #Changes:
  #* added de_at
  #* adapted :pt to pt_br (original :pt was French).
  DATE_TEXTS = {
   :ca => {
      :monthnames => [nil] + %w{gener febrer març abril maig juny juliol agost setembre octubre novembre desembre},
      :abbr_monthnames => [nil] + %w{gen feb mar abr mai jun jul ago set oct nov des},
      :daynames => %w{diumenge dilluns dimarts dimecres dijous divendres dissabte},
      :abbr_daynames => %w{dmg dll dmt dmc djs dvn dsb},
     },
   :cf => {
      :monthnames => [nil] + %w{Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre},
      :abbr_monthnames => [nil] + %w{Jan Fev Mar Avr Mai Jun Jui Aou Sep Oct Nov Dec},
      :daynames => %w{Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi},
      :abbr_daynames => %w{Dim Lun Mar Mer Jeu Ven Sam},
     },
   :cs => {
      :monthnames => [nil] + %w{Leden Únor Březen Duben Květen Červen Červenec Srpen Září Říjen Listopad Prosinec},
      :abbr_monthnames => [nil] + %w{Led Úno Bře Dub Kvě Čvn Čvc Srp Zář Říj Lis Pro},
      :daynames => %w{Neděle Pondělí Úterý Středa Čtvrtek Pátek Sobota},
      :abbr_daynames => %w{Ne Po Út St Čt Pá So},
     },
   :da => {
      :monthnames => [nil] + %w{januar februar marts april maj juni juli august september oktober november december},
      :abbr_monthnames => [nil] + %w{jan feb mar apr maj jun jul aug sep okt nov dec},
      :daynames => %w{søndag mandag tirsdag onsdag torsdag fredag lørdag},
      :abbr_daynames => %w{søn man tir ons tors fre lør},
     },
   :de => {
      :monthnames => [nil] + %w{Januar Februar März April Mai Juni Juli August September Oktober November Dezember},
      :abbr_monthnames => [nil] + %w{Jan Feb Mrz Apr Mai Jun Jul Aug Sep Okt Nov Dez},
      :daynames => %w{Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag},
      :abbr_daynames => %w{So Mo Di Mi Do Fr Sa},
     },
    :de_at => {
        :monthnames => [nil] + %w(Jänner Feber März April Mai Juni Juli August September Oktober November Dezember),
        :abbr_monthnames => [nil] + %w(Jan Feb Mrz Apr Mai Jun Jul Aug Sep Okt Nov Dez),
        :daynames => %w(Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag),
        :abbr_daynames => %w(So Mo Di Mi Do Fr Sa),
      },     
   :en => {
      :monthnames => [nil] + %w{January February March April May June July August September October November December},
      :abbr_monthnames => [nil] + %w{Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec},
      :daynames => %w{Sunday Monday Tuesday Wednesday Thursday Friday Saturday},
      :abbr_daynames => %w{Sun Mon Tue Wed Thu Fri Sat},
     },
   :es => {
      :monthnames => [nil] + %w{enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre},
      :abbr_monthnames => [nil] + %w{ene feb mar abr may jun jul ago sep oct nov dic},
      :daynames => %w{domingo lunes martes miércoles jueves viernes sábado},
      :abbr_daynames => %w{dom lun mar mié jue vie sáb},
     },
   :es_ar => {
      :monthnames => [nil] + %w{enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre},
      :abbr_monthnames => [nil] + %w{ene feb mar abr may jun jul ago sep oct nov dic},
      :daynames => %w{domingo lunes martes miércoles jueves viernes sábado},
      :abbr_daynames => %w{dom lun mar mié jue vie sáb},
     },
   :fi => {
      :monthnames => [nil] + %w{tammikuu helmikuu maaliskuu huhtikuu toukokuu kesäkuu heinäkuu elokuu syyskuu lokakuu marraskuu joulukuu},
      :abbr_monthnames => [nil] + %w{tammi helmi maalis huhti touko kesä heinä elo syys loka marras joulu},
      :daynames => %w{sunnuntai maanantai tiistai keskiviikko torstai perjantai lauantai},
      :abbr_daynames => %w{su ma ti ke to pe la},
     },
   :fr => {
      :monthnames => [nil] + %w{Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Decembre},
      :abbr_monthnames => [nil] + %w{Jan Fév Mar Avr Mai Jui Jul Aoû Sep Oct Nov Déc},
      :daynames => %w{Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi},
      :abbr_daynames => %w{Dim Lun Mar Mer Jeu Ven Sam},
     },
   :it => {
      :monthnames => [nil] + %w{Gennaio Febbraio Marzo Aprile Maggio Giugno Luglio Agosto Settembre Ottobre Novembre Dicembre },
      :daynames => %w{ Domenica Lunedì Martedì Mercoledì Giovedì Venerdì Sabato },
      :abbr_monthnames => [nil] + %w{ Gen Feb Mar Apr Mag Giu Lug Ago Set Ott Nov Dic },
      :abbr_daynames => %w{ Dom Lun Mar Mer Gio Ven Sab },
     },
   :ko => {
      :monthnames => [nil] + %w{1월 2월 3월 4월 5월 6월 7월 8월 9월 10월 11월 12월},
      :abbr_monthnames => [nil] + %w{1 2 3 4 5 6 7 8 9 10 11 12},
      :daynames => %w{일요일 월요일 화요일 수요일 목요일 금요일 토요일},
      :abbr_daynames => %w{일 월 화 수 목 금 토},
     },
   :nl => {
      :monthnames => [nil] + %w{Januari Februari Maart April Mei Juni Juli Augustus September Oktober November December},
      :abbr_monthnames => [nil] + %w{Jan Feb Maa Apr Mei Jun Jul Aug Sep Okt Nov Dec},
      :daynames => %w{Zondag Maandag Dinsdag Woensdag Donderdag Vrijdag Zaterdag},
      :abbr_daynames => %w{Zo Ma Di Wo Do Vr Za},
     },
   :no => {
      :monthnames => [nil] + %w{januar februar mars april mai juni juli august september oktober november desember},
      :abbr_monthnames => [nil] + %w{jan feb mar apr mai jun jul aug sep okt nov des},
      :daynames => %w{søndag mandag tirsdag onsdag torsdag fredag lørdag},
      :abbr_daynames => %w{søn man tir ons tors fre lør},
     },
   :pt => {
      :monthnames => [nil] + %w{Janeiro Fevereiro Março Abril Maio Junho Julho Agosto Setembro Outubro Novembro Dezembro},
      :abbr_monthnames => [nil] + %w{Jan Fev Mar Abr Mai Jun Jul Ago Set Out Nov Dez},
      :daynames => %w{domingo segunda terça quarta quinta sexta sábado},
      :abbr_daynames => %w{Dom Seg Ter Qua Qui Sex Sab},
     },
   :pt_br => {
      :monthnames => [nil] + %w{janeiro fevereiro março abril maio junho julho agosto setembro outubro novembro dezembro},
      :abbr_monthnames => [nil] + %w{jan fev mar abr mai jun jul ago set out nov dez},
      :daynames => %w{domingo segunda terça quarta quinta sexta sábado},
      :abbr_daynames => %w{dom seg ter qua qui sex sáb},
     },
   :ru => {
      :monthnames => [nil] + %w{Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь},
      :abbr_monthnames => [nil] + %w{Янв Фев Мар Апр Май Июн Июл Авг Сен Окт Ноя Дек},
      :daynames => %w{Воскресенье Понедельник Вторник Среда Четверг Пятница Суббота},
      :abbr_daynames => %w{Вск Пнд Втр Сре Чет Пят Суб},
     },
   :sv => {
      :monthnames => [nil] + %w{januari februari mars april maj juni juli augusti september oktober november december},
      :abbr_monthnames => [nil] + %w{jan feb mar apr maj jun jul aug sep okt nov dec},
      :daynames => %w{söndag måndag tisdag onsdag torsdag fredag lördag},
      :abbr_daynames => %w{sön mån tis ons tors fre lör},
     },
   :sr => {
      :monthnames => [nil] + %w{Januar Februar Mart April Maj Jun Jul Avgust Septembar Oktobar Novembar Decembar},
      :abbr_monthnames => [nil] + %w{Jan Feb Mar Apr Maj Jun Jul Aug Sep Okt Nov Dec},
      :daynames => %w{Nedelja Ponedeljak Utorak Sreda Četvrtak Petak Subota},
      :abbr_daynames => %w{Ned Pon Uto Sre Čet Pet Sub},
     },
   :hu => {
      :monthnames => [nil] + %w{január február március május június július augusztus szeptember október november december},
      :abbr_monthnames => [nil] + %w{jan feb már ápr máj jún júl aug sze okt nov dec},
      :daynames => %w{vasárnap hétfő kedd szerda csütörtök péntek szombat},
      :abbr_daynames => %w{vas hét ked sze csü pén szo},
     },
  }
  #~ puts DATE_TEXTS.to_yaml
    
  #Not really necessary.
  #But I want to avoid later changes.
  DATE_TEXTS.freeze
    
  #
  #Test if the seleted language is available in Date_locale.
  def self.locale?( lang )
    return DATE_TEXTS[lang]
  end
  
  #Set default converter
  #~ @@encoding_converter = Iconv.new( 'iso-8859-1', 'utf-8' )
  
  #
  #The daynames are encoded in UTF (I hope ;-) ).
  #With this method you can define a global converter.
  #
  #Example:
  #     Date_locale.set_target_encoding( 'iso-8859-1')
  #
  def self.set_target_encoding( enc )
    @@encoding_converter = Iconv.new( enc, 'utf-8' )
  end


  #
  #Get the key for the wanted language.
  #
  #Allows the usage (or not to use) locale.
  def self.get_language_key( lang = nil )
    
    #
    #What's the better solution? Check for locale, or check for the method :language?
    #
    #if defined?( Locale ) and lang.is_a?(Locale::TagList)
    if lang.respond_to?(:language)
    	if lang.respond_to?(:charset) && lang.charset != nil
				Date_locale.set_target_encoding( lang.charset )
			end
      return lang.language.to_sym
    end
    
    case lang
      when nil  #Undefined default, take actual locale or en
        return defined?( Locale ) ? Locale.current.language.to_sym : :en
      #This code require locale (or you get an error "uninitialized constant Date_locale::Locale")
      #when Locale::Object
      #  return lang.language.to_sym
      else
        return lang.to_sym
      end
  end

  #
  #strftime with the day- and month names in the selected language.
  #
  #Lang can be a language symbol or a locale.
  def strftime_locale(format = '%F', lang = nil )
    
    lang = Date_locale.get_language_key(lang)
    
    #Get the texts
    if DATE_TEXTS[lang]
      daynames = DATE_TEXTS[lang][:daynames]
      abbr_daynames = DATE_TEXTS[lang][:abbr_daynames]
      monthnames  = DATE_TEXTS[lang][:monthnames]
      abbr_monthnames = DATE_TEXTS[lang][:abbr_monthnames]
    else
      #raise "Missing Support for locale #{lang.inspect}"
      #fallback to english
			daynames = DATE_TEXTS[:en][:daynames]
			abbr_daynames = DATE_TEXTS[:en][:abbr_daynames]
			monthnames  = DATE_TEXTS[:en][:monthnames]
			abbr_monthnames = DATE_TEXTS[:en][:abbr_monthnames]
    end
    
    #Make the original replacements, after....
    result = self.strftime_orig( 
      #...you replaced the language dependent parts.
      format.gsub(/%([aAbB])/){|m|
            case $1
              when 'a'; abbr_daynames[self.wday]
              when 'A'; daynames[self.wday]
              when 'b'; abbr_monthnames[self.mon]
              when 'B'; monthnames[self.mon]
              else
                raise "Date#strftime: InputError"
            end
          }
        )
    if defined? @@encoding_converter
      @@encoding_converter.iconv(result)
    else
      result
    end
  end #strftime_locale(format = '%F', lang = :en )

end #module Date_locale

class Date

  include Date_locale
  alias :strftime_orig :strftime

  #Redefine strftime with flexible daynames.
  #
  def strftime(format = '%F', lang = nil )
    return strftime_locale(format, lang )
   end #strftime
end #class Date


#
#Redefine strftime for DateTime
#
class DateTime
  #No alias! It is done already in class Date.
  #alias :strftime_orig_date :strftime
  
  #Redefine strftime.
  #strftime_orig is already defined in Date.
  def strftime( format='%F', lang = nil )
    return strftime_locale(format, lang )
  end #strftime
end


class Time
  include Date_locale  
  alias :strftime_orig :strftime
  #Redefine strftime for locale versions.
  def strftime(format='%F', lang = nil )
    return strftime_locale(format, lang )
  end #strftime
  
end

#
#Make some quick tests
#
if __FILE__ == $0
  #~ require 'date_locale'
  
  d = Date.new(2009,10,21)
  puts d.strftime("de: %A {%a} {%A} {%W}  %w ", :de ) #=> de: Mittwoch {Mi} {Mittwoch} {42}  3 (loc: en)
  puts d.strftime("en: %A {%a} {%A} {%W}  %w ", :en ) #=> en: Wednesday {Wed} {Wednesday} {42}  3 (loc: en)
  
  puts "=======Load locale"
  require 'locale'
  Locale.current = 'de'
  puts d.strftime("#{Locale.current}: %A {%a} {%A} {%W}  %w") #=> de: Mittwoch {Mi} {Mittwoch} {42}  3
  Locale.current = 'en'
  puts d.strftime("#{Locale.current}: %A {%a} {%A} {%W}  %w") #=> en: Wednesday {Wed} {Wednesday} {42}  3
  puts d.strftime("de: %A {%a} {%A} {%W}  %w (loc: #{Locale.current})", :de ) #=> de: Mittwoch {Mi} {Mittwoch} {42}  3 (loc: en)
  puts d.strftime("en: %A {%a} {%A} {%W}  %w (loc: #{Locale.current})", :en ) #=> en: Wednesday {Wed} {Wednesday} {42}  3 (loc: en)
end #if __FILE__ == $0
