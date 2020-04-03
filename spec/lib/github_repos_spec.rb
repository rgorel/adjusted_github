require 'lib/github_repos'
require 'ostruct'

describe GithubRepos do
  let(:client_id) { 'such id' }
  let(:client_secret) { 'so secret' }

  let(:dummy_client) { double('github client') }

  before do
    allow(Octokit::Client).to(
      receive(:new)
        .with(client_id: client_id, client_secret: client_secret)
        .and_return(dummy_client)
    )
  end

  subject(:service) { described_class.new(client_id: client_id, client_secret: client_secret) }

  def generate_result(count:, total_count:)
    items = count.times.map do |i|
      OpenStruct.new(
        full_name: "snoopies/snoopy#{i}",
        description: "Describe me!",
        html_url: "github.com/snoopies/snoopy#{i}",
        snoopy_id: i
      )
    end

    OpenStruct.new(total_count: total_count, items: items)
  end

  describe '#search' do
    shared_context 'returning empty result' do
      it 'returns empty result without calling external service' do
        expect(dummy_client).not_to receive(:search_repositories)

        result = subject
        expect(result.items).to be_empty
        expect(result.total_count).to be_zero
        expect(result.next_page).to be_nil
        expect(result.previous_page).to be_nil
      end
    end

    context 'when empty query is given' do
      subject { service.search('') }

      it_behaves_like 'returning empty result'
    end

    context 'when null query is given' do
      subject { service.search(nil) }

      it_behaves_like 'returning empty result'
    end

    context 'when non-empty query is given' do
      let(:page) { 1 }
      let(:per_page) { 3 }
      let(:returned_count_on_page) { 3 }
      let(:returned_total_count) { 3 }

      subject { service.search('snoopy on snails', page: page, per_page: per_page) }

      let(:result) { subject }

      before do
        allow(dummy_client).to(
          receive(:search_repositories)
          .with("snoopy on snails is:public", page: page, per_page: per_page)
          .and_return(generate_result(count: returned_count_on_page, total_count: returned_total_count))
        )
      end

      context 'when the result fits in one page' do
        it 'returns the result and there are no pages' do
          expect(result.page).to eq 1
          expect(result.per_page).to eq 3

          expect(result.items.map(&:name)).to eq [
            'snoopies/snoopy0',
            'snoopies/snoopy1',
            'snoopies/snoopy2',
          ]

          expect(result.items.map(&:url)).to eq [
            'github.com/snoopies/snoopy0',
            'github.com/snoopies/snoopy1',
            'github.com/snoopies/snoopy2',
          ]

          expect(result.items.map(&:description)).to all eq 'Describe me!'

          expect(result.next_page).to be_nil
          expect(result.previous_page).to be_nil
        end
      end

      context 'when the result is paged' do
        let(:returned_total_count) { 7 }

        it 'gets the next page but not previous page' do
          expect(result.page).to eq 1
          expect(result.total_pages).to eq 3
          expect(result.next_page).to eq 2
          expect(result.previous_page).to be_nil
        end

        context 'when we are on the second page' do
          let(:page) { 2 }

          it 'gets previous and next page' do
            expect(result.page).to eq 2
            expect(result.next_page).to eq 3
            expect(result.previous_page).to eq 1
          end
        end

        context 'when we are on the last page' do
          let(:page) { 3 }

          it 'gets previous but not next page' do
            expect(result.page).to eq 3
            expect(result.next_page).to be_nil
            expect(result.previous_page).to eq 2
          end
        end
      end
    end
  end
end
