require 'rom/cache'

RSpec.describe ROM::Cache do
  subject(:cache) { ROM::Cache.new }

  describe '#fetch_or_store' do
    it 'returns existing object' do
      obj = 'foo'

      expect(cache.fetch_or_store(obj) { obj })
      expect(cache.fetch_or_store(obj)).to be(obj)
    end
  end

  context 'namespace cache' do
    describe '#fetch_or_store' do
      it 'returns existing object' do
        namespaced = cache.namespaced('stuff')
        obj = 'foo'

        expect(namespaced.fetch_or_store(obj) { obj })
        expect(namespaced.fetch_or_store(obj)).to be(obj)
      end
    end
  end
end
