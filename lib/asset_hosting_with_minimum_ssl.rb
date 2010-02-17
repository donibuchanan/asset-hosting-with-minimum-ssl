class AssetHostingWithMinimumSsl
  attr_accessor :asset_host, :ssl_asset_host, :only, :except
  
  def initialize(asset_host, ssl_asset_host, options={})
    self.asset_host, self.ssl_asset_host = asset_host, ssl_asset_host
    if options[:only]
      self.only = Regexp.union(options[:only])
    end
    if options[:except]
      self.except = Regexp.union(options[:except])
    end
  end
  
  def call(source, request)
    if request.ssl?
      case
      when javascript_file?(source)
        ssl_asset_host(source)
      when safari?(request)
        asset_host(source)
      when firefox?(request) && image_file?(source)
        asset_host(source)
      else
        ssl_asset_host(source)
      end
    else
      asset_host(source)
    end
  end
  
  
  private
    def asset_host(source)
      return '' if no_asset_source(source)
      @asset_host % (source.hash % 4)
    end

    def ssl_asset_host(source)
      return '' if no_asset_source(source)
      @ssl_asset_host % (source.hash % 4)
    end

    def no_asset_source(source)
      if only and (source =~ only).nil?
        true
      elsif except and !(source =~ except).nil?
        true
      end
    end    

    def javascript_file?(source)
      source =~ /\.js$/
    end
    
    def image_file?(source)
      source =~ /^\/images/
    end


    def safari?(request)
      request.headers["USER_AGENT"] =~ /Safari/
    end
    
    def firefox?(request)
      request.headers["USER_AGENT"] =~ /Firefox/
    end
end
