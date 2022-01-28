# frozen_string_literal: true

require 'spec_helper'
require 'facter'

describe 'falcon_sensor' do
  subject(:fact) { Facter.fact(:falcon_sensor) }
  RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

  before do
    # before each test
    Facter.clear
    allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
#    allow(Facter::Util::Resolution).to receive(:exec).and_return(nil)
  end


  context 'when falcon_sensor is not installed' do
    it 'returns nil' do
      allow(Facter::Util::Resolution).to receive(:exec)
        .with('/opt/CrowdStrike/falconctl -g --aid --apd --aph --app       --rfm-state --rfm-reason --version --tags')
        .and_return(nil)
      expect(Facter.fact(:falcon_sensor).value).to be_nil
    end
  end

  context 'has no aid' do
    it 'returns version' do
      Puppet::Util::Log.level = :debug
      Puppet::Util::Log.newdestination(:console)
      allow(Facter::Util::Resolution).to receive(:exec)
        .with('/opt/CrowdStrike/falconctl -g --aid --apd --aph --app       --rfm-state --rfm-reason --version --tags')
        .and_return('aid is not set, apd is not set, aph is not set, app is not set, rfm-state=true, rfm-reason=Unspecified, code=0xC0000001, version = 5.34.9918.0Sensor grouping tags are not set')
      expect(Facter.fact(:falcon_sensor).value).to eq({
                                                        'version' => '5.34.9918.0',
                                                        'code' => '0xc0000001',
                                                        'rfm-state' => "true",
                                                        'rfm-reason' => 'unspecified',
                                                      })
    end
  end
end
