# Fluent::Stackprof

Using fluent-stackprof, you can start and stop [stackprof](https://github.com/tmm1/stackprof) dynamically from outside of fluentd without any configuration changes.

## Pareparation for Fluentd

You must run your fluentd daemon with `in_debug_agent` plugin and `stackprof` gem installed.
Also, ruby >= 2.1 is required to run `stackprof`. 

Install `stackprof` gem,

```
$ fluent-gem install stackprof
```

`in_debug_agent` plugin is required to be enabled.

```
<source>
  type debug_agent
  port 24230
</source>
```

## Install

`fluent-stackprof` is a command line utility which connects to your fluentd daemon from outside (it would be another host).
Prepare ruby >= 2.1, and install as:

```
$ gem install fluent-stackprof
$ gem install stackprof
```

## Usage


Start

```
$ fluent-stackprof start -h localhost -p 24230
```

Stop and write a profiling result.

```
$ fluent-stackprof stop -h localhost -p 24230 -o /tmp/fluent-stackprof.dump
```

Then, use `stackprof` to analyze the resulting file:

```
$ stackprof /tmp/fluent-stackprof.dump --text --limit 1
```

See [stackprof#run](https://github.com/tmm1/stackprof#run) for more details. 
The author's blog article is also helpful [Ruby 2.1: Profiling Ruby by @tmm1](http://tmm1.net/ruby21-profiling).

## Options

|parameter|description|default|
|---|---|---|
|-h, --host HOST|fluent host|127.0.0.1|
|-p, --port PORT|debug_agent port|24230|
|-u, --unix PATH|use unix socket instead of tcp||
|-o, --output PATH|output file|/tmp/fluent-stackprof.txt|
|-m, --mode MODE|stackprof measure mode. See [stackprof#sampling](https://github.com/tmm1/stackprof#sampling)|cpu|

## ChangeLog

See [CHANGELOG.md](./CHANGELOG.md)

## Contributing

1. Fork it ( http://github.com/sonots/fluent-stackprof/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

See [LICENSE.txt](./LICENSE.txt)
