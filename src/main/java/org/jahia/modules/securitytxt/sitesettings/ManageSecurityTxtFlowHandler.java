/**
 * ==========================================================================================
 * =                   JAHIA'S DUAL LICENSING - IMPORTANT INFORMATION                       =
 * ==========================================================================================
 *
 *                                 http://www.jahia.com
 *
 *     Copyright (C) 2002-2017 Jahia Solutions Group SA. All rights reserved.
 *
 *     THIS FILE IS AVAILABLE UNDER TWO DIFFERENT LICENSES:
 *     1/GPL OR 2/JSEL
 *
 *     1/ GPL
 *     ==================================================================================
 *
 *     IF YOU DECIDE TO CHOOSE THE GPL LICENSE, YOU MUST COMPLY WITH THE FOLLOWING TERMS:
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *
 * 2/ JSEL - Commercial and Supported Versions of the program
 * ===================================================================================
 *
 * IF YOU DECIDE TO CHOOSE THE JSEL LICENSE, YOU MUST COMPLY WITH THE FOLLOWING TERMS:
 *
 * Alternatively, commercial and supported versions of the program - also known as Enterprise Distributions - must be
 * used in accordance with the terms and conditions contained in a separate written agreement between you and Jahia
 * Solutions Group SA.
 *
 * If you are unsure which license is appropriate for your use, please contact the sales department at sales@jahia.com.
 */
package org.jahia.modules.securitytxt.sitesettings;

import java.io.Serializable;
import javax.jcr.Node;
import javax.jcr.NodeIterator;
import javax.jcr.RepositoryException;
import javax.jcr.Workspace;
import javax.jcr.query.Query;
import org.apache.commons.lang.StringEscapeUtils;
import org.apache.commons.lang.StringUtils;
import org.jahia.services.content.JCRCallback;
import org.jahia.services.content.JCRContentUtils;
import org.jahia.services.content.JCRNodeWrapper;
import org.jahia.services.content.JCRSessionWrapper;
import org.jahia.services.content.JCRStoreProvider;
import org.jahia.services.content.JCRStoreService;
import org.jahia.services.content.JCRTemplate;
import org.jahia.services.content.decorator.JCRSiteNode;
import org.jahia.services.render.RenderContext;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.webflow.execution.RequestContext;

public class ManageSecurityTxtFlowHandler implements Serializable {

    private static final Logger LOGGER = LoggerFactory.getLogger(ManageSecurityTxtFlowHandler.class);
    private static final String SECURITY_TXT = "securitytxt";
    private static final String SECURITY_TXT_NODE_TYPE = "jnt:securitytxt";

    public JCRNodeWrapper getSiteSecurityTxt(RequestContext ctx) throws RepositoryException {
        final JCRSiteNode currentSite = getRenderContext(ctx).getSite();
        final JCRNodeWrapper securityNode;
        if (currentSite.hasNode(SECURITY_TXT)) {
            securityNode = currentSite.getNode(SECURITY_TXT);
        } else {
            securityNode = currentSite.addNode(SECURITY_TXT, SECURITY_TXT_NODE_TYPE);
        }
        return securityNode;
    }

    public String getFilesList(RequestContext ctx) {
        final JCRSiteNode currentSite = getRenderContext(ctx).getSite();
        final JSONObject result = new JSONObject();
        try {
            final JSONArray files = JCRTemplate.getInstance().doExecuteWithSystemSession(new JCRCallback<JSONArray>() {
                @Override
                public JSONArray doInJCR(JCRSessionWrapper session) throws RepositoryException {
                    return getSiteFiles(session.getWorkspace(), currentSite, "files", "jnt:file");
                }
            });

            result.put("folders", files);
        } catch (RepositoryException e) {
            LOGGER.error("Error trying to retrieve local folders", e);
        } catch (JSONException e) {
            LOGGER.error("Error trying to construct JSON from local folders", e);
        }

        return result.toString();
    }

    public String getPagesList(RequestContext ctx) {
        final JCRSiteNode currentSite = getRenderContext(ctx).getSite();
        final JSONObject result = new JSONObject();
        try {
            final JSONArray pages = JCRTemplate.getInstance().doExecuteWithSystemSession(new JCRCallback<JSONArray>() {
                @Override
                public JSONArray doInJCR(JCRSessionWrapper session) throws RepositoryException {
                    return getSiteFiles(session.getWorkspace(), currentSite, "home", "jnt:page");
                }
            });

            result.put("folders", pages);
        } catch (RepositoryException e) {
            LOGGER.error("Error trying to retrieve local folders", e);
        } catch (JSONException e) {
            LOGGER.error("Error trying to construct JSON from local folders", e);
        }

        return result.toString();
    }

    private RenderContext getRenderContext(RequestContext ctx) {
        return (RenderContext) ctx.getExternalContext().getRequestMap().get("renderContext");
    }

    protected JSONArray getSiteFiles(Workspace workspace, JCRSiteNode site, String relPath, String type) throws RepositoryException {
        final JSONArray folders = new JSONArray();
        Node siteFiles = null;
        try {
            siteFiles = site.getNode(relPath);
            final JSONObject jSONObject = new JSONObject();
            try {
                jSONObject.accumulate("path", escape(siteFiles.getPath()));
                jSONObject.accumulate("UUID", siteFiles.getIdentifier());
            } catch (JSONException ex) {
                LOGGER.error("Impossible to create json object", ex);
            }
            folders.put(jSONObject);
        } catch (RepositoryException e) {
            // no files under the site
        }
        if (siteFiles != null) {
            final StringBuilder filter = new StringBuilder("isdescendantnode(f,['").append(JCRContentUtils.sqlEncode(siteFiles.getPath())).append("'])");
            for (JCRStoreProvider provider : JCRStoreService.getInstance().getSessionFactory().getProviderList()) {
                if (!provider.isDefault() && StringUtils.startsWith(provider.getMountPoint(), siteFiles.getPath())) {
                    filter.append(" and (not isdescendantnode(f,['").append(JCRContentUtils.sqlEncode(provider.getMountPoint())).append("']))");
                }
            }

            final Query siteFoldersQuery = workspace.getQueryManager().createQuery("select * from [" + type + "] as f where " + filter, Query.JCR_SQL2);

            final NodeIterator siteDatas = siteFoldersQuery.execute().getNodes();
            while (siteDatas.hasNext()) {
                final Node siteData = siteDatas.nextNode();
                final JSONObject jSONObject = new JSONObject();
                try {
                    jSONObject.accumulate("path", escape(siteData.getPath()));
                    jSONObject.accumulate("UUID", siteData.getIdentifier());
                } catch (JSONException ex) {
                    LOGGER.error("Impossible to create json object", ex);
                }
                folders.put(jSONObject);
            }
        }

        return folders;
    }

    private String escape(String path) {
        return StringUtils.isNotEmpty(path) ? StringEscapeUtils.escapeXml(path) : path;
    }
}
