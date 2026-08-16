require 'rails_helper'

RSpec.describe Order, type: :model do
  it { is_expected.to belong_to(:table) }
  it { is_expected.to have_many(:order_items).dependent(:destroy) }
  it { is_expected.to have_many(:checks).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:opened_at) }

  it 'is valid with valid attributes' do
    expect(build(:order)).to be_valid
  end

  describe 'status enum' do
    it { is_expected.to define_enum_for(:status).with_values(open: 1, closed: 2) }

    it 'defaults to open' do
      order = described_class.new
      expect(order.open?).to be true
    end

    it 'returns true for closed? when status is closed' do
      order = build(:order, status: :closed)
      expect(order.closed?).to be true
      expect(order.open?).to be false
    end

    it 'pins the open value to 1, matching the partial unique index\'s where: "status = 1" clause' do
      # The orders migration's partial unique index hardcodes `where: "status = 1"`
      # to enforce one open order per table. If this enum is ever renumbered,
      # the index would silently stop matching open orders instead of failing
      # loudly, so this spec exists to catch that renumbering immediately.
      expect(Order.statuses[:open]).to eq(1)
    end
  end

  describe '.open' do
    it 'returns only orders with open status' do
      open_order = create(:order, status: :open)
      create(:order, status: :closed)

      expect(described_class.open.to_a).to eq([ open_order ])
    end
  end

  describe '.open_for' do
    it 'returns the open order for the given table' do
      table = create(:table)
      order = create(:order, table: table, status: :open)
      create(:order, table: table, status: :closed)
      create(:order, status: :open) # a different table entirely

      expect(described_class.open_for(table).to_a).to eq([ order ])
    end

    it 'returns none when the table has no open order' do
      table = create(:table)
      create(:order, table: table, status: :closed)

      expect(described_class.open_for(table).to_a).to eq([])
    end
  end

  describe 'one open order per table (database-enforced)' do
    it 'rejects a second open order for a table that already has one, even bypassing application code' do
      table = create(:table)
      create(:order, table: table, status: :open)

      expect do
        described_class.create!(table: table, opened_at: Time.current)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows a new open order once the previous one is closed' do
      table = create(:table)
      create(:order, table: table, status: :closed)

      expect do
        described_class.create!(table: table, opened_at: Time.current)
      end.not_to raise_error
    end

    it 'allows open orders on two different tables at the same time' do
      create(:order, table: create(:table), status: :open)

      expect do
        described_class.create!(table: create(:table), opened_at: Time.current)
      end.not_to raise_error
    end
  end

  describe 'table broadcasting' do
    it 'broadcasts a table replace to the commerce stream on create' do
      table = create(:table)
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)

      order = create(:order, table: table)

      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        "commerce_#{table.commerce_id}_tables",
        target: ActionView::RecordIdentifier.dom_id(table),
        partial: "app/tables/table",
        locals: { table: table, open: true }
      )
    end

    it 'broadcasts a table replace to the commerce stream on destroy' do
      table = create(:table)
      order = create(:order, table: table)

      expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).with(
        "commerce_#{table.commerce_id}_tables",
        target: ActionView::RecordIdentifier.dom_id(table),
        partial: "app/tables/table",
        locals: { table: table, open: false }
      )

      order.destroy
    end

    it 'does not fail the create when the broadcast itself raises' do
      table = create(:table)
      allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to).and_raise(StandardError, "redis down")

      expect do
        create(:order, table: table)
      end.not_to raise_error
      expect(Order.where(table_id: table.id).count).to eq(1)
    end
  end
end
