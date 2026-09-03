---
layout: base
title: Testing Functions
icon: fa fa-superscript
breadcrumbs:
    -
        name: Documentation
        path: /rspec-puppet/documentation/
---

## Basic Test Structure

{% highlight ruby %}
require 'spec_helper'

describe '<function name>' do
  # tests go here
end
{% endhighlight %}

The name of the function being tested must be provided as the top level
description (`<function name>` in the above example).

## The run matcher

### Specifying the arguments to the function

Arguments to the function can be specified by chaining the `with_params` method
on to the `run` matcher

{% highlight ruby %}
it { is_expected.to run.with_params('foo', 'bar') }
{% endhighlight %}

### Passing lambdas to the function

A lambda (block) can be passed to functions that support either a required or
optional lambda by chaining the `with_lambda` method on to the `run` matcher.

{% highlight ruby %}
it { is_expected.to run.with_lambda { |x| x * 2 } }
{% endhighlight %}

### Testing the return value

The return value of the function can be tested by chaining the `and_return`
method on to the `run` matcher.

{% highlight ruby %}
it { is_expected.to run.with_params('foo').and_return('bar') }
{% endhighlight %}

### Testing for errors

If the function is expected to raise an exception (for example, when testing
input validation), this can be tested by chaining the `and_raise_error` method
on to the `run` matcher.

{% highlight ruby %}
it { is_expected.to run.with_params('foo').and_raise_error(Puppet::ParseError, 'some message') }
{% endhighlight %}

### Accessing the parser scope

Some complex functions require access to the parser's scope (for example,
functions that look up values of variables that are not passed in as
arguments). For this reason, the scope is available to the tests as the
`scope` object.

Using the above example, to stub out a `lookupvar` call that the function
being tested uses, the following could be used (if using rspec-mocks).

{% highlight ruby %}

before do
  allow(scope).to receive(:lookupvar).with('some_variable').and_return('some value')
end

{% endhighlight %}

## Testing functions that modify the catalogue

If the function being tested modifies the catalogue in some way, the standard
catalogue matchers (as used when testing classes or defined types) are
available to be used.

An example of a function where this is needed is the `ensure_resource` function
from puppetlabs/stdlib which adds resources to the catalogue.

The catalogue is exposed to the tests as the `catalogue` object.

{% highlight ruby %}
describe 'ensure_resource' do
  it 'creates a resource in the catalogue' do
    is_expected.to run.with_params('user', 'lak', {'ensure' => 'present'})
    expect(catalogue).to contain_user('lak').with_ensure('present')
  end
end
{% endhighlight %}

## Mocking a function for use in all tests
    
You may not need to test a function itself, but a calling class may require the function
to return a value. You can mock the function once and make it available to all test.
Modify *spec/spec_helper.rb* (or *spec/spec_helper__local.rb* if you use the PDK) and
use `Puppet::Parser::Functions.newfunction()` to add the function inside of an
`RSpec.configure` block. For example:
    
{% highlight ruby %}
RSpec.configure do | c|
  c.before :each do
    # The vault_lookup function takes a single argument and returns a hash with three keys
    Puppet::Parser::Functions.newfunction(:vault_lookup, type: :rvalue) do |_args|
      {
        domain: 'test',
        username: 'test',
        password: 'test'
      }
    end
  end
end
{% endhighlight %}

You may add multiple functions and other configuration elements inside the `c.before :each do`
block and all will be available inside every test.
