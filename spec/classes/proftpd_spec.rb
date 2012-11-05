#!/usr/bin/env rspec

require 'spec_helper'

describe 'proftpd' do
  it { should contain_class 'proftpd' }
end
