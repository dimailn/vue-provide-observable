# props is the hash with name => value

export installer = {
  install: (Vue, options) ->
    return if Vue::$vpo

    Vue::$vpo = {}
    Vue::$vpo.Vue = Vue
}

export default (pluginName, propsFactory, nameMapper = (name) -> name) ->

  return console.error "You must provide props factory" unless typeof propsFactory is 'function'

  props = propsFactory()

  provide: ->
    vue = @$root.$vpo?.Vue || Object.getPrototypeOf(@$root).constructor

    provide = {
      "#{pluginName}": { wrapper: {} }
    }
    provide[pluginName].wrapper = vue.observable(
      propsFactory()
    )

    @["$_vueProvideObservable_#{pluginName}_wrapper"] = provide[pluginName].wrapper

    provide

  created: ->
    @["$_vueProvideObservable_#{pluginName}_wrapper_update"]()

  updated: ->
    @["$_vueProvideObservable_#{pluginName}_wrapper_update"]()

  # TO DO: optimize
  watch:
    Object.keys(props).reduce(
      (obj, name) ->
        obj[nameMapper(name)] = -> @["$_vueProvideObservable_#{pluginName}_wrapper_update"]()
        obj
      {}
    )

  methods:
    "$_vueProvideObservable_#{pluginName}_wrapper_update": ->
      for name of props
        @["$_vueProvideObservable_#{pluginName}_wrapper"][name] = @[nameMapper(name)]


