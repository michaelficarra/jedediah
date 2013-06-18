MAX_WIDTH = 85

wrap = (lhsWidth, input) ->
  rhsWidth = MAX_WIDTH - lhsWidth
  pad = (Array lhsWidth + 4 + 1).join ' '
  rows = while input.length
    row = input[...rhsWidth]
    input = input[rhsWidth..]
    row
  rows.join "\n#{pad}"

formatOptions = (opts) ->
  opts = for opt in opts when opt.length
    if opt.length is 1 then "-#{opt}" else "--#{opt}"
  opts.sort (a, b) -> a.length - b.length
  opts.join ', '

addAliases = (name, aliases, aliasMap, shortList, longList) ->
  for alias in [name, aliases...]
    aliasMap[alias] = name
    if alias.length is 1 then shortList.push alias
    else if alias.length > 1 then longList.push alias


class Option
  constructor: (@name, @aliases, @default, @description) ->
class Parameter
  constructor: (@name, @aliases, @placeholder, @description) ->
  default: -> null
class ListParameter
  constructor: (@name, @aliases, @placeholder, @description) ->
  default: -> []


module.exports = class Jedediah
  @Jedediah: this
  constructor: ->
    # initialise options
    @options = {}
    @parameters = {}
    @aliasMap = {}
    # allowed short/long option arguments
    @shortOptionArguments = []
    @longOptionArguments = []
    # allowed short/long parameter arguments
    @shortParameterArguments = []
    @longParameterArguments = []

  addOption: (name, aliases..., default_, description) ->
    @options[name] = new Option name, aliases, (-> default_), description
    addAliases name, aliases, @aliasMap, @shortOptionArguments, @longOptionArguments

  addParameter: (name, aliases..., placeholder, description) ->
    @parameters[name] = new Parameter name, aliases, placeholder, description
    addAliases name, aliases, @aliasMap, @shortParameterArguments, @longParameterArguments

  addListParameter: (name, aliases..., placeholder, description) ->
    @parameters[name] = new ListParameter name, aliases, placeholder, description
    addAliases name, aliases, @aliasMap, @shortParameterArguments, @longParameterArguments

  addAlias: -> # TODO

  getDefaults: ->
    obj = {}
    obj[k] = o.default() for own k, o of @options
    obj[k] = o.default() for own k, o of @parameters
    obj

  parse: (argv) ->
    # clone args
    args = argv[1 + (argv[0] is 'node') ..]
    # ignore args after --
    additionalArgs = []
    if '--' in args
      additionalArgs = (args.splice (args.indexOf '--'), 9e9)[1..]

    # define some regexps that match allowed arguments
    reShortOptions = ///^ - (#{@shortOptionArguments.join '|'})+ $///
    reLongOption = ///^ -- (no-)? (#{@longOptionArguments.join '|'}) $///
    reShortParameter = ///^ - (#{@shortParameterArguments.join '|'}) $///
    reLongParameter = ///^ -- (#{@longParameterArguments.join '|'}) $///
    reShortOptionsShortParameter = ///
      ^ - (#{@shortOptionArguments.join '|'})+
      (#{@shortParameterArguments.join '|'}) $
    ///

    options = @getDefaults()

    # parse arguments
    positionalArgs = []
    while args.length
      arg = args.shift()
      if @shortParameterArguments.length and reShortOptionsShortParameter.exec arg
        args.unshift "-#{arg[1...-1]}", "-#{arg[-1..]}"
      else if reShortOptions.exec arg
        for o in arg[1..].split ''
          options[@aliasMap[o]] = on
      else if match = reLongOption.exec arg
        options[@aliasMap[match[2]]] = if match[1]? then off else on
      else if match = (reShortParameter.exec arg) ? reLongParameter.exec arg
        if @parameters[@aliasMap[match[1]]] instanceof ListParameter
          options[@aliasMap[match[1]]].push args.shift()
        else
          options[@aliasMap[match[1]]] = args.shift()
      else if match = /^(-.|--.*)$/.exec arg
        throw new Error "Unrecognised option '#{match[0].replace /'/g, '\\\''}'"
      else
        positionalArgs.push arg

    positionalArgs = positionalArgs.concat additionalArgs

    [options, positionalArgs]

  help: ->
    optionRows = for own name, opt of @options
      [(formatOptions [opt.name].concat(opt.aliases)), opt.description]
    parameterRows = for own name, opt of @parameters
      ["#{formatOptions [opt.name].concat(opt.aliases)} #{opt.placeholder}", opt.description]
    leftColumnWidth = [optionRows..., parameterRows...].reduce ((memo, opt) -> Math.max memo, opt[0].length), 0

    rows = [optionRows..., parameterRows...]
    rows.sort (a, b) ->
      a = a[0]; b = b[0]
      if a[0..1] is '--' and b[0..1] isnt '--' then return 1
      if b[0..1] is '--' and a[0..1] isnt '--' then return -1
      if a.toLowerCase() < b.toLowerCase() then -1 else 1
    formattedRows = for row in rows
      "  #{row[0]}#{(Array leftColumnWidth - row[0].length + 1).join ' '}  #{wrap leftColumnWidth, row[1]}"
    formattedRows.join "\n"
