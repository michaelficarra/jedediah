module.exports = class Jedediah
  constructor: (@optionArguments = [], @parameterArguments = []) ->

  parse: (argv) ->
    # clone args
    args = argv[1 + (argv[0] is 'node') ..]
    # ignore args after --
    additionalArgs = []
    if '--' in args
      additionalArgs = (args.splice (args.indexOf '--'), 9e9)[1..]

    # initialise options
    options = {}
    optionMap = {}

    # collect allowed short/long option arguments
    shortOptionArguments = []
    longOptionArguments = []
    for opts in @optionArguments
      options[opts[0][0]] = opts[1]
      for o in opts[0]
        optionMap[o] = opts[0][0]
        if o.length is 1 then shortOptionArguments.push o
        else if o.length > 1 then longOptionArguments.push o

    # collect allowed short/long parameter arguments
    shortParameterArguments = []
    longParameterArguments = []
    for opts in @parameterArguments
      for o in opts[0]
        optionMap[o] = opts[0][0]
        if o.length is 1 then shortParameterArguments.push o
        else if o.length > 1 then longParameterArguments.push o

    # define some regexps that match allowed arguments
    reShortOptions = ///^ - (#{shortOptionArguments.join '|'})+ $///
    reLongOption = ///^ -- (no-)? (#{longOptionArguments.join '|'}) $///
    reShortParameter = ///^ - (#{shortParameterArguments.join '|'}) $///
    reLongParameter = ///^ -- (#{longParameterArguments.join '|'}) $///
    reShortOptionsShortParameter = ///
      ^ - (#{shortOptionArguments.join '|'})+
      (#{shortParameterArguments.join '|'}) $
    ///

    # parse arguments
    positionalArgs = []
    while args.length
      arg = args.shift()
      if reShortOptionsShortParameter.exec arg
        args.unshift "-#{arg[1...-1]}", "-#{arg[-1..]}"
      else if reShortOptions.exec arg
        for o in arg[1..].split ''
          options[optionMap[o]] = on
      else if match = reLongOption.exec arg
        options[optionMap[match[2]]] = if match[1]? then off else on
      else if match = (reShortParameter.exec arg) ? reLongParameter.exec arg
        options[optionMap[match[1]]] = args.shift()
      else if match = /^(-.|--.*)$/.exec arg
        console.error "Unrecognised option '#{match[0].replace /'/g, '\\\''}'"
        process.exit 1
      else
        positionalArgs.push arg

    positionalArgs = positionalArgs.concat additionalArgs

    [options, positionalArgs]

Jedediah.Jedediah = Jedediah
