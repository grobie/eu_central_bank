require 'spec_helper'
require 'yaml'

describe "EuCentralBank" do

  before(:all) do
    @tmp_cache_directory = File.expand_path(File.dirname(__FILE__) + '/tmp')
    Dir.mkdir(@tmp_cache_directory) unless File.exists?(@tmp_cache_directory)
    @yml_cache_path = File.expand_path(File.dirname(__FILE__) + '/exchange_rates.yml')
    @cache_path = File.expand_path(File.dirname(__FILE__) + '/exchange_rates.xml')
    @tmp_cache_path = File.expand_path(@tmp_cache_directory + '/exchange_rates.xml')
    @exchange_rates = YAML.load_file(@yml_cache_path)
  end

  before(:each) do
    mock(Money).deprecate("EuCentralBank is deprecated and will be removed in v0.2.0. Use Money::Bank::EuCentral instead.")
    @bank = EuCentralBank.new
  end

  after(:each) do
    if File.exists? @tmp_cache_path
      File.delete @tmp_cache_path
    end
  end

  it "should save the xml file from ecb given a file path" do
    @bank.save_rates(@tmp_cache_path)
    File.exists?(@tmp_cache_path).should == true
  end

  it "should raise an error if an invalid path is given to save_rates" do
    lambda { @bank.save_rates(nil) }.should raise_exception
  end

  it "should update itself with exchange rates from ecb website" do
    stub(OpenURI::OpenRead).open(EuCentralBank::ECB_RATES_URL) {@cache_path}
    @bank.update_rates
    EuCentralBank::CURRENCIES.each do |currency|
      @bank.get_rate("EUR", currency).should > 0
    end
  end

  it "should update itself with exchange rates from cache" do
    @bank.update_rates(@cache_path)
    EuCentralBank::CURRENCIES.each do |currency|
      @bank.get_rate("EUR", currency).should > 0
    end
  end

  it "should return the correct exchange rates using exchange" do
    @bank.update_rates(@cache_path)
    EuCentralBank::CURRENCIES.each do |currency|
      mock(Money).deprecate("`exchange` will be removed in money v3.2.0 and eu_central_bank v0.2.0, use #exchange_with instead")
      @bank.exchange(100, "EUR", currency).cents.should == (@exchange_rates["currencies"][currency].to_f * 100).floor
    end
  end

  it "should return the correct exchange rates using exchange_with" do
    @bank.update_rates(@cache_path)
    EuCentralBank::CURRENCIES.each do |currency|
      @bank.exchange_with(Money.new(100, "EUR"), currency).cents.should == (@exchange_rates["currencies"][currency].to_f * 100).floor
    end
  end
end
