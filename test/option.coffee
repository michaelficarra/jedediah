suite 'options', ->

  test 'basic option', ->
    parser = new Jedediah
    eq undefined, parser.parse([])[0].abc
    parser.addOption 'abc', off, 'description'
    eq on, (parser.parse ['', '--abc'])[0].abc

  test 'default value', ->
    parser = new Jedediah
    eq undefined, parser.parse([])[0].abc
    parser.addOption 'abc', off, 'description'
    parser.addOption 'def', on, 'description'
    eq off, parser.parse([])[0].abc
    eq on, (parser.parse ['', '--abc'])[0].abc
    eq on, parser.parse([])[0].def
    eq on, (parser.parse ['', '--def'])[0].def

  test 'description included in help', ->
    parser = new Jedediah
    parser.addOption 'abc', off, 'qwerty'
    ok (parser.help().indexOf 'qwerty') >= 0

  test 'option with aliases', ->
    parser = new Jedediah
    parser.addOption 'abc', 'alias', off, 'description'
    eq on, (parser.parse ['', '--abc'])[0].abc
    eq on, (parser.parse ['', '--alias'])[0].abc

  test 'single-letter alias', ->
    parser = new Jedediah
    parser.addOption 'abc', 'a', off, 'description'
    eq on, (parser.parse ['', '--abc'])[0].abc
    eq on, (parser.parse ['', '-a'])[0].abc

  test '`no-` disables option', ->
    parser = new Jedediah
    parser.addOption 'abc', 'alias', off, 'description'
    eq on, (parser.parse ['', '--abc'])[0].abc
    eq off, (parser.parse ['', '--no-abc'])[0].abc
    eq off, (parser.parse ['', '--no-alias'])[0].abc

  test 'single-letter option', ->
    parser = new Jedediah
    parser.addOption 'a', off, 'description'
    eq on, (parser.parse ['', '-a'])[0].a

  test 'combined options', ->
    parser = new Jedediah
    parser.addOption 'a', off, 'description'
    parser.addOption 'b', off, 'description'
    parser.addOption 'c', off, 'description'
    opts = (parser.parse ['', '-a', '-c', '-b'])[0]
    eq on, opts.a
    eq on, opts.b
    eq on, opts.c
    opts = (parser.parse ['', '-acb'])[0]
    eq on, opts.a
    eq on, opts.b
    eq on, opts.c

  test 'aliases that are the same as the option name', ->
    parser = new Jedediah
    eq undefined, parser.parse([])[0].abc
    parser.addOption 'abc', 'abc', off, 'description'
    eq on, (parser.parse ['', '--abc'])[0].abc
