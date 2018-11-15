require 'rails_helper'

describe SummaryCoachingSession do

  before(:each) do
    @socio = Kleerer.new(name: 'socio',option: :socio, id: 1000)
    @full = Kleerer.new(name: 'full',option: :full, id: 1002)
    @partial = Kleerer.new(name: 'partial',option: :parcial, id: 1003)

    allow(Kleerer).to receive(:find).with(@socio.id).and_return(@socio)
    allow(Kleerer).to receive(:find).with(@full.id).and_return(@full)
    allow(Kleerer).to receive(:find).with(@partial.id).and_return(@partial)

    @create = CreateCoachingSession.new(nil,nil)

    @session_data_dummy = {complementary: 'some complementary info',description: 'description session', date: Time.now.to_s}

  end

  it 'it summarize 1 session with 1 kleerer' do
    coaching_sessions = []
    @create.instance_coaching_session(@session_data_dummy)
    @create.add_kleerers([1000])
    coaching_sessions << @create.coaching_session

    summarizer = SummaryCoachingSession.new(nil,nil)
    result = summarizer.summary(coaching_sessions)

    expect(result[:totalcs]).to eq 1
    expect(result[:distribution].size).to eq 1
    expect(result[:distribution][0][:kleerer]).to eq'socio'
    expect(result[:distribution][0][:sessions]).to eq 1
    expect(result[:distribution][0][:percentage]).to eq 100

  end

  it 'it summarize 1 session with 2 kleerers' do
    coaching_sessions = []
    @create.instance_coaching_session(@session_data_dummy)
    @create.add_kleerers([1000,1002])
    coaching_sessions << @create.coaching_session

    summarizer = SummaryCoachingSession.new(nil,nil)
    result = summarizer.summary(coaching_sessions)

    expect(result[:totalcs]).to eq 1
    expect(result[:distribution].size).to eq 2
    expect(result[:distribution][0][:kleerer]).to eq'socio'
    expect(result[:distribution][0][:sessions]).to eq 0.5
    expect(result[:distribution][0][:percentage]).to eq 50

    expect(result[:distribution][1][:kleerer]).to eq'full'
    expect(result[:distribution][1][:sessions]).to eq 0.5
    expect(result[:distribution][1][:percentage]).to eq 50

  end

  it 'it summarize 1 session with 3 kleerers' do
    coaching_sessions = []
    @create.instance_coaching_session(@session_data_dummy)
    @create.add_kleerers([1000,1002,1003])
    coaching_sessions << @create.coaching_session

    summarizer = SummaryCoachingSession.new(nil,nil)
    result = summarizer.summary(coaching_sessions)

    expect(result[:totalcs]).to eq 1
    expect(result[:distribution].size).to eq 3
    expect(result[:distribution][0][:kleerer]).to eq'socio'
    expect(result[:distribution][0][:sessions]).to eq 0.33
    expect(result[:distribution][0][:percentage]).to eq 33.0

    expect(result[:distribution][1][:kleerer]).to eq'full'
    expect(result[:distribution][1][:sessions]).to eq 0.33
    expect(result[:distribution][1][:percentage]).to eq 33.0

    expect(result[:distribution][2][:kleerer]).to eq'partial'
    expect(result[:distribution][2][:sessions]).to eq 0.33
    expect(result[:distribution][2][:percentage]).to eq 33.0

  end

  it 'it summarize 3 session with 3 kleerers' do
    coaching_sessions = []
    @create.instance_coaching_session(@session_data_dummy)
    @create.add_kleerers([1000])
    coaching_sessions << @create.coaching_session

    @create.instance_coaching_session(@session_data_dummy)
    @create.add_kleerers([1002])
    coaching_sessions << @create.coaching_session

    @create.instance_coaching_session(@session_data_dummy)
    @create.add_kleerers([1003])
    coaching_sessions << @create.coaching_session

    summarizer = SummaryCoachingSession.new(nil,nil)
    result = summarizer.summary(coaching_sessions)

    expect(result[:totalcs]).to eq 3
    expect(result[:distribution].size).to eq 3
    expect(result[:distribution][0][:kleerer]).to eq'socio'
    expect(result[:distribution][0][:sessions]).to eq 1
    expect(result[:distribution][0][:percentage]).to eq 33.33

    expect(result[:distribution][1][:kleerer]).to eq'full'
    expect(result[:distribution][1][:sessions]).to eq 1
    expect(result[:distribution][1][:percentage]).to eq 33.33

    expect(result[:distribution][2][:kleerer]).to eq'partial'
    expect(result[:distribution][2][:sessions]).to eq 1
    expect(result[:distribution][2][:percentage]).to eq 33.33

  end

  it 'it summarize 4 session with 2 kleerers' do
    coaching_sessions = []
    @create.instance_coaching_session(@session_data_dummy)
    @create.add_kleerers([1000,1002])
    coaching_sessions << @create.coaching_session

    @create.instance_coaching_session(@session_data_dummy)
    @create.add_kleerers([1002])
    coaching_sessions << @create.coaching_session

    @create.instance_coaching_session(@session_data_dummy)
    @create.add_kleerers([1000])
    coaching_sessions << @create.coaching_session

    @create.instance_coaching_session(@session_data_dummy)
    @create.add_kleerers([1002])
    coaching_sessions << @create.coaching_session

    summarizer = SummaryCoachingSession.new(nil,nil)
    result = summarizer.summary(coaching_sessions)

    expect(result[:totalcs]).to eq 4
    expect(result[:distribution].size).to eq 2
    expect(result[:distribution][0][:kleerer]).to eq'socio'
    expect(result[:distribution][0][:sessions]).to eq 1.5
    expect(result[:distribution][0][:percentage]).to eq 37.5

    expect(result[:distribution][1][:kleerer]).to eq'full'
    expect(result[:distribution][1][:sessions]).to eq 2.5
    expect(result[:distribution][1][:percentage]).to eq 62.5



  end

end