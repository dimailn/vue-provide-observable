# props is the hash with name => value

vpoWrapperUpdate = ->
  console.log 'vpo wrapper update'

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
    
    Object.keys(@$options.provideObservable).forEach (pluginName) =>
      {propsFactory} = @$options.provideObservable[pluginName]

      data[pluginName] = propsFactory()

    provide = {
      $vpo: { wrapper: new vue({data, $vpo: true}) }
    }

    @["$vpoWrapper"] = provide.$vpo.wrapper

    provide

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

export default {
  install: (Vue, options) ->
    return if Vue::$vpo
    
    Vue.mixin(VueProvideObservableMixin)
    Vue::$vpo = {}
}
