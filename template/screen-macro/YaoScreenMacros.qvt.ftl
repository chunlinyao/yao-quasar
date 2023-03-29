<#--
This software is in the public domain under CC0 1.0 Universal plus a Grant of Patent License.

To the extent possible under law, the author(s) have dedicated all
copyright and related and neighboring rights to this software to the
public domain worldwide. This software is distributed without any
warranty.

You should have received a copy of the CC0 Public Domain Dedication
along with this software (see the LICENSE.md file). If not, see
<http://creativecommons.org/publicdomain/zero/1.0/>.
-->
<#include "component://webroot/../../template/screen-macro/DefaultScreenMacros.qvt.ftl"/>
<#macro "dynamic-dialog">
    <#assign iconClass = "fa fa-share">
    <#if .node["@icon"]?has_content><#assign iconClass = .node["@icon"]></#if>
    <#if .node["@condition"]?has_content><#assign conditionResult = ec.getResource().condition(.node["@condition"], "")><#else><#assign conditionResult = true></#if>
    <#if conditionResult>
        <#-- YAO Added depNodeList -->
        <#assign depNodeList = .node["depends-on"]>
        <#assign buttonText = ec.getResource().expand(.node["@button-text"], "")>
        <#assign title = ec.getResource().expand(.node["@title"], "")>
        <#if !title?has_content><#assign title = buttonText></#if>
        <#assign urlInstance = sri.makeUrlByType(.node["@transition"], "transition", .node, "true")>
        <#assign ddDivId><@nodeId .node/></#assign>
        <#if urlInstance.disableLink>
        <#-- YAO Modify: use iconClass-->
            <q-btn disabled dense outline no-caps icon="${iconClass}" label="${buttonText}" color="<@getQuasarColor ec.getResource().expandNoL10n(.node["@type"]!"primary", "")/>" class="${ec.getResource().expandNoL10n(.node["@button-style"]!"", "")}"></q-btn>
        <#else>
        <#-- YAO Added fields dependsOn, icon-->
            <m-dynamic-dialog id="${ddDivId}" icon="${iconClass}" url="${urlInstance.urlWithParams}" color="<@getQuasarColor ec.getResource().expandNoL10n(.node["@type"]!"primary", "")/>" width="${.node["@width"]!""}"
                    <#t> :depends-on="{<#list depNodeList as depNode><#local depNodeField = depNode["@field"]>'${depNode["@parameter"]!depNodeField}':'${depNodeField}'<#sep>, </#list>}"
                    <#if fieldsJsName?has_content>
                        :fields="${fieldsJsName}"
                    </#if>
                    button-text="${buttonText}" button-class="${ec.getResource().expandNoL10n(.node["@button-style"]!"", "")}" title="${title}"<#if _openDialog! == ddDivId> :openDialog="true"</#if>></m-dynamic-dialog>
        </#if>
        <#-- used to use afterFormText for m-dynamic-dialog inside another form, needed now?
        <#assign afterFormText>
        <m-dynamic-dialog id="${ddDivId}" url="${urlInstance.urlWithParams}" width="${.node["@width"]!""}" button-text="${buttonText}" title="${buttonText}"<#if _openDialog! == ddDivId> :openDialog="true"</#if>></m-dynamic-dialog>
        </#assign>
        <#t>${sri.appendToAfterScreenWriter(afterFormText)}
        -->
    </#if>
</#macro>
<#-- YAO MODIFY, add container-style for big-row -->
<#macro formSingleWidget fieldSubNode formSingleId colPrefix inFieldRow bigRow>
    <#assign fieldSubParent = fieldSubNode?parent>
    <#if fieldSubNode["ignored"]?has_content><#return></#if>
    <#if ec.getResource().condition(fieldSubParent["@hide"]!, "")><#return></#if>
    <#if fieldSubNode["hidden"]?has_content><#recurse fieldSubNode/><#return></#if>
    <#assign containerStyle = ec.getResource().expandNoL10n(fieldSubNode["@container-style"]!, "")>
    <#assign curFieldTitle><@fieldTitle fieldSubNode/></#assign>

    <#assign visibleWhenNode = (fieldSubNode["visible-when"][0])!>
    <#assign visibleAttrText = "">
    <#if visibleWhenNode??>
        <#assign visibleVal = "">
        <#if visibleWhenNode["@from"]?has_content>
            <#assign visibleVal = ec.getResource().expression(visibleWhenNode["@from"], "")!>
        <#else>
            <#assign visibleVal = ec.getResource().expand(visibleWhenNode["@value"]!, "")!>
        </#if>
        <#if visibleVal?has_content>
            <#-- NOTE: FreeMarker is sometimes ridiculous, is_string returns true even if the type is ArrayList in one test case, so DO NOT TRUST is_string!!! -->
            <#if visibleVal?is_string && !visibleVal?is_enumerable && visibleVal?contains(",")><#assign visibleVal = visibleVal?split(",")></#if>
            <#if visibleVal?is_enumerable>
                <#assign visibleAttrText> :style="{display:([<#list visibleVal as entryVal>'${entryVal}'<#sep>,</#list>].includes(formProps.fields.${visibleWhenNode["@field"]})?'':'none')}"</#assign>
            <#else>
                <#assign visibleAttrText> :style="{display:('${visibleVal}'==formProps.fields.${visibleWhenNode["@field"]}?'':'none')}"</#assign>
            </#if>
        </#if>
    </#if>
    <#if bigRow>
        <div class="q-mx-sm q-my-auto big-row-item<#if containerStyle?has_content> ${containerStyle}</#if>"${visibleAttrText}>
    <#else>
        <div class="q-ma-sm<#if containerStyle?has_content> ${containerStyle}</#if>"${visibleAttrText}>
    </#if>
    <#t>${sri.pushContext()}
    <#assign fieldFormId = formSingleId><#-- set this globally so fieldId macro picks up the proper formSingleId, clear after -->
    <#list fieldSubNode?children as widgetNode><#if widgetNode?node_name == "set">${sri.setInContext(widgetNode)}</#if></#list>
    <#list fieldSubNode?children as widgetNode>
        <#if widgetNode?node_name == "link">
            <#assign linkNode = widgetNode>
            <#if linkNode["@condition"]?has_content><#assign conditionResult = ec.getResource().condition(linkNode["@condition"], "")><#else><#assign conditionResult = true></#if>
            <#if conditionResult>
                <#if linkNode["@entity-name"]?has_content>
                    <#assign linkText = ""><#assign linkText = sri.getFieldEntityValue(linkNode)>
                <#else>
                    <#assign textMap = "">
                    <#if linkNode["@text-map"]?has_content><#assign textMap = ec.getResource().expression(linkNode["@text-map"], "")!></#if>
                    <#if textMap?has_content><#assign linkText = ec.getResource().expand(linkNode["@text"], "", textMap)>
                        <#else><#assign linkText = ec.getResource().expand(linkNode["@text"]!"", "")></#if>
                </#if>
                <#if linkText == "null"><#assign linkText = ""></#if>
                <#if linkText?has_content || linkNode["image"]?has_content || linkNode["@icon"]?has_content>
                    <#if linkNode["@encode"]! != "false"><#assign linkText = linkText?html></#if>
                    <#assign linkUrlInfo = sri.makeUrlByType(linkNode["@url"], linkNode["@url-type"]!"transition", linkNode, linkNode["@expand-transition-url"]!"true")>
                    <#assign linkFormId><@fieldId linkNode/></#assign>
                    <#assign afterFormText><@linkFormForm linkNode linkFormId linkText linkUrlInfo/></#assign>
                    <#t>${sri.appendToAfterScreenWriter(afterFormText)}
                    <#t><@linkFormLink linkNode linkFormId linkText linkUrlInfo/>
                </#if>
            </#if>
        <#elseif widgetNode?node_name == "set"><#-- do nothing, handled above -->
        <#else><#t><#visit widgetNode>
        </#if>
    </#list>
    <#assign fieldFormId = ""><#-- clear after field so nothing else picks it up -->
    <#t>${sri.popContext()}
    <#if bigRow>
        </div><!-- /big-row-item -->
    <#else>
        </div>
    </#if>
</#macro>

<#macro "text-line">
    <#assign tlSubFieldNode = .node?parent>
    <#assign tlFieldNode = tlSubFieldNode?parent>
    <#assign tlId><@fieldId .node/></#assign>
    <#assign name><@fieldName .node/></#assign>
    <#assign fieldValue = sri.getFieldValueString(.node)>
    <#assign validationClasses = formInstance.getFieldValidationClasses(tlSubFieldNode)>
    <#assign validationRules = formInstance.getFieldValidationJsRules(tlSubFieldNode)!>
    <#-- NOTE: removed number type (<#elseif validationClasses?contains("number")>number) because on Safari, maybe others, ignores size and behaves funny for decimal values -->
    <#if .node["@ac-transition"]?has_content>
        <#assign acUrlInfo = sri.makeUrlByType(.node["@ac-transition"], "transition", .node, "false")>
        <#assign acUrlParameterMap = acUrlInfo.getParameterMap()>
        <#assign acShowValue = .node["@ac-show-value"]! == "true">
        <#assign acUseActual = .node["@ac-use-actual"]! == "true">
        <#if .node["@ac-initial-text"]?has_content><#assign valueText = ec.getResource().expand(.node["@ac-initial-text"]!, "")>
            <#else><#assign valueText = fieldValue></#if>
        <#assign depNodeList = .node["depends-on"]>
        <strong class="text-negative">text-line with @ac-transition is not supported, use drop-down with dynamic-options.@server-search</strong>
        <#--
        <text-autocomplete id="${tlId}" name="${name}" url="${acUrlInfo.url}" value="${fieldValue?html}" value-text="${valueText?html}"<#rt>
                <#t> type="<#if validationClasses?contains("email")>email<#elseif validationClasses?contains("url")>url<#else>text</#if>" size="${.node.@size!"30"}"
                <#t><#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if>
                <#t><#if ec.getResource().condition(.node.@disabled!"false", "")> :disabled="true"</#if>
                <#t><#if validationClasses?has_content> validation-classes="${validationClasses}"</#if>
                <#t><#if validationClasses?contains("required")> :required="true"</#if>
                <#t><#if regexpInfo?has_content> pattern="${regexpInfo.regexp}" data-msg-pattern="${regexpInfo.message!"Invalid format"}"</#if>
                <#t><#if .node?parent["@tooltip"]?has_content> tooltip="${ec.getResource().expand(.node?parent["@tooltip"], "")}"</#if>
                <#t><#if ownerForm?has_content> form="${ownerForm}"</#if>
                <#t><#if .node["@ac-min-length"]?has_content> :min-length="${.node["@ac-min-length"]}"</#if>
                <#t> :depends-on="{<#list depNodeList as depNode><#local depNodeField = depNode["@field"]>'${depNode["@parameter"]!depNodeField}':'<@fieldIdByName depNodeField/>'<#sep>, </#list>}"
                <#t> :ac-parameters="{<#list acUrlParameterMap.keySet() as parameterKey><#if acUrlParameterMap.get(parameterKey)?has_content>'${parameterKey}':'${acUrlParameterMap.get(parameterKey)}', </#if></#list>}"
                <#t><#if .node["@ac-delay"]?has_content> :delay="${.node["@ac-delay"]}"</#if>
                <#t><#if .node["@ac-initial-text"]?has_content> :skip-initial="true"</#if>/>
        -->
    <#else>
        <#assign tlAlign = tlFieldNode["@align"]!"left">
        <#assign fieldLabel><@fieldTitle tlSubFieldNode/></#assign>
        <#if .node["@default-transition"]?has_content>
            <#assign defUrlInfo = sri.makeUrlByType(.node["@default-transition"], "transition", .node, "false")>
            <#assign defUrlParameterMap = defUrlInfo.getParameterMap()>
            <#assign depNodeList = .node["depends-on"]>
        </#if>
        <#assign inputType><#if .node["@input-type"]?has_content>${.node["@input-type"]}<#else><#rt>
            <#lt><#if validationClasses?contains("email")>email<#elseif validationClasses?contains("url")>url<#else>text</#if></#if></#assign>
        <#-- TODO: possibly transform old mask values (for RobinHerbots/Inputmask used in vapps/vuet) -->
        <#-- YAO Added v-model.trim -->
        <#assign expandedMask = ec.getResource().expandNoL10n(.node["@mask"]!"", "")!>
        <m-text-line dense outlined<#if fieldLabel?has_content> stack-label label="${fieldLabel}"</#if> id="${tlId}" type="${inputType}"<#rt>
                <#t> name="${name}"<#if .node.@prefix?has_content> prefix="${ec.resource.expand(.node.@prefix, "")}"</#if>
                <#t> <#if fieldsJsName?has_content>v-model.trim="${fieldsJsName}.${name}" :fields="${fieldsJsName}"<#else><#if fieldValue?html == fieldValue>value="${fieldValue}"<#else>:value="'${Static["org.moqui.util.WebUtilities"].encodeHtmlJsSafe(fieldValue)}'"</#if></#if>
                <#t><#if .node.@size?has_content> size="${.node.@size}"<#else> style="width:100%;"</#if><#if .node.@maxlength?has_content> maxlength="${.node.@maxlength}"</#if>
                <#t><#if formDisabled! || ec.getResource().condition(.node.@disabled!"false", "")> disable</#if>
                <#t> class="<#if validationClasses?has_content>${validationClasses}</#if><#if tlAlign == "center"> text-center<#elseif tlAlign == "right"> text-right</#if>"
                <#t><#if validationClasses?contains("required")> required</#if><#if regexpInfo?has_content> pattern="${regexpInfo.regexp}" data-msg-pattern="${regexpInfo.message!"Invalid format"}"</#if>
                <#t><#if expandedMask?has_content> mask="${expandedMask}" fill-mask="_"<#if validationClasses?contains("number")> :reverse-fill-mask="true"</#if></#if>
                <#t><#if .node["@default-transition"]?has_content>
                    <#t> default-url="${defUrlInfo.path}" :default-load-init="true"<#if .node["@depends-optional"]! == "true"> :depends-optional="true"</#if>
                    <#t> :depends-on="{<#list depNodeList as depNode><#local depNodeField = depNode["@field"]>'${depNode["@parameter"]!depNodeField}':'${depNodeField}'<#sep>, </#list>}"
                    <#t> :default-parameters="{<#list defUrlParameterMap.keySet() as parameterKey><#if defUrlParameterMap.get(parameterKey)?has_content>'${Static["org.moqui.util.WebUtilities"].encodeHtmlJsSafe(parameterKey)}':'${Static["org.moqui.util.WebUtilities"].encodeHtmlJsSafe(defUrlParameterMap.get(parameterKey))}', </#if></#list>}"
                <#t></#if>
                <#t><#if validationRules?has_content || .node.@rules?has_content>
                    <#t> :rules="[<#if .node.@rules?has_content>${.node.@rules},</#if><#list validationRules! as valRule>value => ${Static["org.moqui.util.WebUtilities"].encodeHtmlJsSafe(valRule.expr)}||'${Static["org.moqui.util.WebUtilities"].encodeHtmlJsSafe(valRule.message)}'<#sep>,</#list>]"
                <#t></#if>
                <#lt><#if ownerForm?has_content> form="${ownerForm}"</#if><#if tlSubFieldNode["@tooltip"]?has_content> tooltip="${ec.getResource().expand(tlSubFieldNode["@tooltip"], "")?html}"</#if>></m-text-line>
    </#if>
</#macro>


<#macro "m-luckysheet">
    <#assign tlSubFieldNode = .node?parent>
    <#assign tlFieldNode = tlSubFieldNode?parent>
    <#assign tlId><@fieldId .node/></#assign>
    <#assign name><@fieldName .node/></#assign>
    <#assign dcDivId><@nodeId .node/></#assign>
    <#assign urlInstance = sri.makeUrlByType(.node["@transition"], "transition", .node, "true")>
    <m-luckysheet id="${dcDivId}" 
     <#if fieldsJsName?has_content> 
        :fields="${fieldsJsName}" v-model.trim="${fieldsJsName}.${name}"
    </#if>
     url="${urlInstance.passThroughSpecialParameters().urlWithParams}"></m-luckysheet>
</#macro>