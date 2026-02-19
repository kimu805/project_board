# rspec-rails 4 と Rails 8 の互換性パッチ
# Rails 8 で ActiveRecord::TestFixtures から fixture_path= が削除されたため補完する
if defined?(ActiveRecord::TestFixtures::ClassMethods)
  ActiveRecord::TestFixtures::ClassMethods.module_eval do
    unless method_defined?(:fixture_path=)
      def fixture_path=(path)
        self.fixture_paths = Array(path)
      end
    end
  end
end
