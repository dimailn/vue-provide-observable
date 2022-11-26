# props is the hash with name => value
import {reactive, version} from 'vue'

export installer = {
  install: (Vue, options) ->
    return if Vue.config.globalProperties.$vpo

    Vue.config.globalProperties.$vpo = {}
    Vue.config.globalProperties.$vpo.Vue = Vue
}

export default (
  pluginName
  propsFactory
  nameMapper = (name) -> name
  shouldProvide = (component) -> true
) ->

  return console.error "You must provide props factory" unless typeof propsFactory is 'function'

  props = propsFactory()

  vpoWrapperUpdate = ->
    for name of props
      @["$__vpo__#{pluginName}"].wrapper[name] = @[nameMapper(name)]

  provide: ->
    return {} unless shouldProvide(@)

    vue = @$root.$vpo?.Vue || Object.getPrototypeOf(@$root).constructor

    provide = {
      "#{pluginName}": { wrapper: {} }
    }

    provide[pluginName].wrapper = reactive(
      propsFactory()
    )

    @["$__vpo__#{pluginName}"] = {
      wrapper: provide[pluginName].wrapper
      watchers: []
    }

    provide

  created: ->
    return unless shouldProvide(@)

    @["$__vpo__#{pluginName}"].watchers = Object.keys(props).map((name) =>
      # TO DO: optimize
      @$watch(nameMapper(name), vpoWrapperUpdate.bind(@))
    )

    vpoWrapperUpdate.call(@)

  beforeDestroy: ->
    return unless shouldProvide(@)

    @["$__vpo__#{pluginName}"].watchers.forEach((unwatch) -> unwatch())

  updated: ->
    return unless shouldProvide(@)

    vpoWrapperUpdate.call(@)




