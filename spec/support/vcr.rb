VCR.configure do |c|
  c.cassette_library_dir = 'spec/factories/vcr_cassettes'
  c.hook_into :webmock
end
