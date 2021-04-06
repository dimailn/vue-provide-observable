# props is the hash with name => value

vpoWrapperUpdate = ->
  return if this.$options.$vpo

  Object.keys(@$options.provideObservable).forEach (pluginName) =>
    {nameMapper} = @$options.provideObservable[pluginName]

    for name in Object.keys(@["$vpoWrapper"][pluginName])
      @["$vpoWrapper"][pluginName][name] = @[nameMapper(name)]

VueProvideObservableMixin = {
  provide: ->
    return unless @$options.provideObservable

    return if @$options.$vpo


    vue = Object.getPrototypeOf(@$root).constructor

    data = {}
    localPluginNames = Object.keys(@$options.provideObservable)

    localPluginNames.forEach (pluginName) =>
      {propsFactory} = @$options.provideObservable[pluginName]

      data[pluginName] = propsFactory()


    computed = Object.keys(@$vpo.wrapper.$options?.data || {}).filter((pluginName) -> !localPluginNames.includes(pluginName)).reduce(
      (computed, pluginName) => computed[pluginName] = => @$vpo.wrapper[pluginName]; computed
      {}
    )

    provide = {
      $vpo: { wrapper: new vue({data, $vpo: true, computed}) }
    }

    @["$vpoWrapper"] = provide.$vpo.wrapper

    provide

  inject:
    $vpo: {
      'default': { wrapper: { } }
    }

  created: ->
    return unless @$options.provideObservable

    return if this.$options.$vpo
    

    # TO DO: optimize
    Object.keys(@$options.provideObservable).forEach (pluginName) =>
      {nameMapper} = @$options.provideObservable[pluginName]

      Object.keys(@["$vpoWrapper"][pluginName]).forEach (propertyName) =>
        @$watch(
          nameMapper(propertyName)
          =>
            # hotfix, replace with programmatically watch

            return if this.$options.$vpo

            vpoWrapperUpdate.bind(this)()
        )

    vpoWrapperUpdate.bind(this)()

  updated: ->
    return unless @$options.provideObservable

    return if this.$options.$vpo

    vpoWrapperUpdate.bind(this)()

}

VueProvideObservable = {
  install: (Vue, options) ->
    return if Vue::$vpoOptions
    
    Vue.mixin(VueProvideObservableMixin)
    Vue::$vpoOptions = {}
}

