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
    <#if bigRow><#-- YAO Added class='column' div -->
        <div class="column"><div class="q-mx-sm q-my-auto big-row-item"${visibleAttrText}>
    <#else>
        <div class="column"><div class="q-ma-sm<#if containerStyle?has_content> ${containerStyle}</#if>"${visibleAttrText}>
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
        </div></div><!-- /big-row-item -->
    <#else>
        </div></div>
    </#if>
</#macro>