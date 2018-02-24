<%@ taglib prefix="query" uri="http://www.jahia.org/tags/queryLib" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<c:set target="${renderContext}" property="contentType" value="text/plain;charset=UTF-8"/>
<c:forEach items="${jcr:getChildrenOfType(currentNode.properties['signature'].node, 'jnt:resource')}" var="data">
    <c:if test="${data.name eq 'jcr:content'}">
        ${data.properties['jcr:data']}
    </c:if>
</c:forEach>
