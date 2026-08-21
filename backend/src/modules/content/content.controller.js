"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.createContent = createContent;
exports.listContent = listContent;
exports.getContentById = getContentById;
exports.updateContent = updateContent;
exports.submitForReview = submitForReview;
exports.approveContent = approveContent;
exports.rejectContent = rejectContent;
exports.publishContent = publishContent;
exports.archiveContent = archiveContent;
const contentService = __importStar(require("./content.service"));
const content_schema_1 = require("./content.schema");
function getAuthenticatedUserId(req) {
    if (!req.user) {
        throw new Error("Authenticated user is missing from request.");
    }
    return req.user.id;
}
async function createContent(req, res, next) {
    try {
        const body = content_schema_1.createContentBodySchema.parse(req.body);
        const created = await contentService.createContent({
            ...body,
            createdBy: getAuthenticatedUserId(req),
        });
        res.status(201).json(created);
    }
    catch (err) {
        next(err);
    }
}
async function listContent(req, res, next) {
    try {
        const filter = content_schema_1.listContentQuerySchema.parse(req.query);
        const items = await contentService.listContent(filter);
        res.status(200).json(items);
    }
    catch (err) {
        next(err);
    }
}
async function getContentById(req, res, next) {
    try {
        const { id } = content_schema_1.idParamSchema.parse(req.params);
        const item = await contentService.getContentById(id);
        res.status(200).json(item);
    }
    catch (err) {
        next(err);
    }
}
async function updateContent(req, res, next) {
    try {
        const { id } = content_schema_1.idParamSchema.parse(req.params);
        const input = content_schema_1.updateContentBodySchema.parse(req.body);
        const updated = await contentService.updateContent(id, input);
        res.status(200).json(updated);
    }
    catch (err) {
        next(err);
    }
}
async function submitForReview(req, res, next) {
    try {
        const { id } = content_schema_1.idParamSchema.parse(req.params);
        const updated = await contentService.submitForReview({
            contentId: id,
            submittedBy: getAuthenticatedUserId(req),
        });
        res.status(200).json(updated);
    }
    catch (err) {
        next(err);
    }
}
async function approveContent(req, res, next) {
    try {
        const { id } = content_schema_1.idParamSchema.parse(req.params);
        const updated = await contentService.approveContent({
            contentId: id,
            approvedBy: getAuthenticatedUserId(req),
        });
        res.status(200).json(updated);
    }
    catch (err) {
        next(err);
    }
}
async function rejectContent(req, res, next) {
    try {
        const { id } = content_schema_1.idParamSchema.parse(req.params);
        const { comment } = content_schema_1.rejectContentBodySchema.parse(req.body);
        const updated = await contentService.rejectContent({
            contentId: id,
            rejectedBy: getAuthenticatedUserId(req),
            comment,
        });
        res.status(200).json(updated);
    }
    catch (err) {
        next(err);
    }
}
async function publishContent(req, res, next) {
    try {
        const { id } = content_schema_1.idParamSchema.parse(req.params);
        const updated = await contentService.publishContent({
            contentId: id,
            publishedBy: getAuthenticatedUserId(req),
        });
        res.status(200).json(updated);
    }
    catch (err) {
        next(err);
    }
}
async function archiveContent(req, res, next) {
    try {
        const { id } = content_schema_1.idParamSchema.parse(req.params);
        const updated = await contentService.archiveContent({
            contentId: id,
            archivedBy: getAuthenticatedUserId(req),
        });
        res.status(200).json(updated);
    }
    catch (err) {
        next(err);
    }
}
