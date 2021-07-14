# frozen_string_literal: true

require "rom/runtime"

RSpec.describe ROM::Runtime do
  subject(:runtime) do
    ROM::Runtime.new
  end

  let(:registry) do
    runtime.registry
  end

  it "can define a dataset" do
    dataset = runtime.dataset(:users) { [1, 2] }

    expect(dataset.config[:id]).to be(:users)
    expect(dataset.config[:gateway]).to be(nil)

    expect(registry["datasets.users"]).to eql([1, 2])
  end

  it "can define a dataset with a gateway" do
    runtime.gateway(:default, adapter: :memory)
    runtime.dataset(:users, gateway: :default)

    expect(registry["datasets.users"]).to be_a(ROM::Memory::Dataset)
  end

  it "can define a schema" do
    schema = runtime.schema(:users, adapter: :memory)

    expect(schema.config[:id]).to be(:users)
    expect(schema.config[:gateway]).to be(:default)

    expect(registry["schemas.users"]).to be_a(ROM::Schema)
  end

  it "can define a relation" do
    runtime.gateway(:default, adapter: :memory)
    runtime.dataset(:users, adapter: :memory, gateway: :default)

    relation = runtime.relation(:users, adapter: :memory)

    expect(relation.config[:id]).to be(:users)
    expect(relation.config[:dataset]).to be(:users)
    expect(relation.config[:gateway]).to be(:default)

    users = registry["relations.users"]

    expect(users).to be_a(ROM::Memory::Relation)
    expect(users.dataset).to be_a(ROM::Memory::Dataset)
  end

  it "can define a relation with a schema" do
    runtime.gateway(:default, adapter: :memory)

    relation = runtime.relation(:users, adapter: :memory) do
      schema { attribute(:id, ROM::Types::Integer) }
    end

    expect(relation.config[:id]).to be(:users)
    expect(relation.config[:dataset]).to be(:users)
    expect(relation.config[:gateway]).to be(:default)

    users = registry["relations.users"]

    expect(users).to be_a(ROM::Memory::Relation)
    expect(users.schema).to be_a(ROM::Schema)
    expect(users.schema[:id]).to be_a(ROM::Attribute)
  end

  it "can define a relation with a schema with its own dataset id" do
    runtime.gateway(:default, adapter: :memory)

    relation = runtime.relation(:people, adapter: :memory) do
      schema(:users) { attribute(:id, ROM::Types::Integer) }
    end

    expect(relation.config[:id]).to be(:people)
    expect(relation.config[:gateway]).to be(:default)

    users = registry["relations.people"]
    schema = registry["schemas.users"]

    expect(users).to be_a(ROM::Memory::Relation)
    expect(users.name.dataset).to be(:users)

    expect(users.schema).to be(schema)
    expect(users.schema).to be_a(ROM::Schema)
    expect(users.schema[:id]).to be_a(ROM::Attribute)
  end

  it "can define commands" do
    runtime.gateway(:default, adapter: :memory)

    runtime.relation(:users, adapter: :memory)

    commands = runtime.commands(:users, adapter: :memory) do
      define(:create)
    end

    expect(commands.size).to be(1)

    component = commands.first

    expect(component.config[:id]).to be(:create)
    expect(component.config[:adapter]).to be(:memory)
    expect(component.config[:relation_id]).to be(:users)

    command = registry["commands.users.create"]

    expect(command).to be_a(ROM::Memory::Commands::Create)
  end

  it "can define mappers" do
    mappers = runtime.mappers do
      define(:users)
      define(:tasks)
    end

    expect(mappers.size).to be(2)

    users_mapper, tasks_mapper = mappers.to_a

    expect(users_mapper.id).to be(:users)
    expect(users_mapper.relation_id).to be(:users)

    expect(tasks_mapper.id).to be(:tasks)
    expect(tasks_mapper.relation_id).to be(:tasks)
  end

  it "can define a local plugin" do
    pending "FIXME: configuring a local plugin should copy the canonical plugin"

    plugin = runtime.plugin(:memory, schemas: :timestamps)

    expect(plugin.key).to eql("schema.timestamps")
    expect(plugin).to_not be(ROM.plugin_registry[plugin.key])
  end
end