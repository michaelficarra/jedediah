suite 'List Parameters', ->

  test 'list parameter defaults to []', ->
    parser = new Jedediah
    parser.addListParameter 'abc', 'placeholder', 'description'
    arrayEq [], (parser.parse [''])[0].abc

  test 'single instance produces 1-element array', ->
    parser = new Jedediah
    parser.addListParameter 'abc', 'placeholder', 'description'
    arrayEq ['def'], (parser.parse ['', '--abc', 'def'])[0].abc

  test 'N instances produce N-element array', ->
    parser = new Jedediah
    parser.addListParameter 'abc', 'placeholder', 'description'
    opts = (n.toString() for n in [0..9])
    passed = ['']
    passed.push '--abc', n for n in opts
    arrayEq opts, (parser.parse passed)[0].abc
