require "selenium-webdriver"

class Browser

  def initialize(browser = :chrome, url)
    @browser = browser
    @url = url
  end

  def run
    case @browser
    when :firefox
      firefox.get @url
      firefox
    when :chrome
      chrome.get @url
      chrome
    when :watir
      watir.goto @url
      watir
    end
  end

  private

  def chrome
    # window-size=1280,960
    # proxy = Selenium::WebDriver::Proxy.new(http: take_proxy)
    # cap = Selenium::WebDriver::Remote::Capabilities.chrome(proxy: proxy)

    options = %w[no-sandbox enable-javascript start-maximized ]
    options = Selenium::WebDriver::Chrome::Options.new(args: options)
    # options.add_option 'excludeSwitches', ['enable-automation']

    options.add_argument('lang=ru')
    options.add_argument("disable-blink-features")
    options.add_argument("disable-blink-features=AutomationControlled")
    options.add_argument('window-size=1920x1080')
    options.add_argument('ignore-certificate-errors')
    options.add_argument('allow-running-insecure-content')
    options.add_argument('disable-gpu')
    options.add_argument('disable-geolocation')
    options.add_argument('ignore-certificate-errors')
    options.add_argument('disable-popup-blocking')
    options.add_argument('disable-web-security')
    options.add_argument('disable-infobars')
    options.add_argument('disable-translate')
    options.add_argument("enable-aggressive-domstorage-flushing")
    options.add_argument("profiling-flush=10")
    options.add_argument("headless")
    # options.add_argument("disable-logging")
    # options.add_argument('allow-profiles-outside-user-dir')
    # options.add_argument("user-data-dir=/home/seluser/chrome_profile")
    # options.add_argument("profile-directory=Person 1")

    # options.add_argument("binary=/usr/bin/google-chrome")
    # Selenium::WebDriver::Chrome.path = '/usr/bin/google-chrome'

    client = Selenium::WebDriver::Remote::Http::Default.new
    client.read_timeout = 60

    @chrome ||= Selenium::WebDriver.for(:remote, :url => ENV['CHROME_ADDRESS'],
                                        capabilities: [options],
                                        http_client: client)
  end

  def take_proxy
    proxy_list = ProxyFetcher::Manager.new(filters: { country: 'RU', maxtime: '500' })
    proxy_list.raw_proxies.sample.delete('//')
  end

  def firefox
    options = Selenium::WebDriver::Firefox::Options.new(args: [''])

    driver = Selenium::WebDriver.for(:firefox, options: options)
  end

  def watir
    browser = Watir::Browser.new :chrome, proxy: { http: take_proxy }
  end
end