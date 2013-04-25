require 'action_view'
require 'show_for/helper'

module ShowFor
  autoload :Builder, 'show_for/builder'

  mattr_accessor :show_for_tag
  @@show_for_tag = :div

  mattr_accessor :show_for_class
  @@show_for_class = nil

  mattr_accessor :label_tag
  @@label_tag = :strong

  mattr_accessor :label_class
  @@label_class = :label

  mattr_accessor :separator
  @@separator = "<br />"

  mattr_accessor :content_tag
  @@content_tag = nil

  mattr_accessor :content_class
  @@content_class = :content

  mattr_accessor :blank_content_class
  @@blank_content_class = "blank"

  mattr_accessor :wrapper_tag
  @@wrapper_tag = :p

  mattr_accessor :wrapper_class
  @@wrapper_class = :wrapper

  mattr_accessor :collection_tag
  @@collection_tag = :ul

  mattr_accessor :collection_class
  @@collection_class = :collection

  mattr_accessor :default_collection_proc
  @@default_collection_proc = lambda { |value| "<li>#{ERB::Util.html_escape(value)}</li>".html_safe }

  mattr_accessor :i18n_format
  @@i18n_format = :default
  
  # Default translation mechanism is I18n - but you may set it to :ar if you'd like to use ActiveRecord Translations
  mattr_accessor :translation_mechanism
  @@translation_mechanism = :i18n

  mattr_accessor :association_methods
  @@association_methods = [ :name, :title, :to_s ]

  mattr_accessor :label_proc
  @@label_proc = nil

  # Yield self for configuration block:
  #
  #   ShowFor.setup do |config|
  #     config.i18n_format = :long
  #   end
  #
  def self.setup
    yield self
  end

  # isolating the translation call enables us to offer various translation methods
  def self.t(*args)
    key=args.shift
    options=args.shift || {}
    case @@translation_mechanism
    when :i18n; I18n.t(key,options)
    when :ar;   self.active_record_translations(key,options)
    end
  end

  # isolating the translation call enables us to offer various translation methods
  def self.l(*args)
    value=args.shift
    options=args.shift || {}
    case @@translation_mechanism
    when :i18n; I18n.l(value,options)
    when :ar;   I18n.l(value,options)
    end
  end
  
  # active_record_translations
  # provided by means of extending the I18n
  #
  # module I18n
  #   class << self
  #     def oxt key, args={}
  #       scope_prefix =args.include?( :prefix ) ? ".#{args.delete(:prefix)}" : ""
  #       scope_suffix =args.include?( :suffix ) ? ".#{args.delete(:suffix)}" : ""
  #       domain =  self.respond_to?(:resource_class) ? resource_class.to_s.underscore.downcase : "omni"
  #       args.merge!( scope: "oxenserver#{scope_prefix}.#{domain}#{scope_suffix}" )
  #       t(key.to_sym, args )
  #     end
  # 
  #     # SELECT DISTINCT locale FROM `translations`  WHERE (translations.ox_id='1') AND (translations.state='production')
  #     def available_locales(ox_id=ENV['OX_ID'], state=nil)
  #       state ||= 'production'
  #       Translation.unscoped.find(:all, :select => 'DISTINCT locale', :conditions => ["ox_id=? AND state=?", ox_id, state]).map { |t| t.locale.to_sym }
  #     end
  # 
  #   end
  # 
  # end
  def self.active_record_translations(key,options)
    I18n.oxt(key,options)
  end
  
end
