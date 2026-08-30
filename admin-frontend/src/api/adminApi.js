import { apiClient } from './client';

export const adminApi = {
  // Auth
  login: async (usernameOrEmail, password) => {
    const res = await apiClient.post('/auth/login/', {
      email: usernameOrEmail,
      username: usernameOrEmail,
      password,
    });
    return res.data;
  },

  // Dashboard KPIs & Trends
  getDashboardStats: async (params = {}) => {
    const res = await apiClient.get('/admin/stats/', { params });
    return res.data;
  },

  // Video Tasks
  getVideoTasks: async () => {
    const res = await apiClient.get('/admin/tasks/');
    return res.data;
  },
  createVideoTask: async (data) => {
    const res = await apiClient.post('/admin/tasks/', data);
    return res.data;
  },
  updateVideoTask: async (id, data) => {
    const res = await apiClient.patch(`/admin/tasks/${id}/`, data);
    return res.data;
  },
  deleteVideoTask: async (id) => {
    const res = await apiClient.delete(`/admin/tasks/${id}/`);
    return res.data;
  },
  regenerateKeywords: async (id) => {
    const res = await apiClient.post(`/admin/tasks/${id}/regenerate-keywords/`);
    return res.data;
  },
  fetchYouTubeMeta: async (url) => {
    const res = await apiClient.post('/admin/tasks/fetch-youtube-meta/', { youtube_url: url });
    return res.data;
  },

  // AI Settings & Sandbox
  getAISettings: async () => {
    const res = await apiClient.get('/admin/ai-settings/');
    return res.data;
  },
  updateAISettings: async (data) => {
    const res = await apiClient.patch('/admin/ai-settings/', data);
    return res.data;
  },
  fetchAIModels: async (provider, apiKey = '') => {
    const params = { provider };
    if (apiKey) params.api_key = apiKey;
    const res = await apiClient.get('/admin/ai-settings/fetch-models/', { params });
    return res.data;
  },
  testAISandbox: async (data) => {
    const res = await apiClient.post('/admin/ai-settings/test-sandbox/', data);
    return res.data;
  },

  // Watch Sessions & Telemetry
  getWatchSessions: async (params = {}) => {
    const res = await apiClient.get('/admin/watch-sessions/', { params });
    return res.data;
  },
  getLiveWatchSessions: async () => {
    const res = await apiClient.get('/admin/watch-sessions/live/');
    return res.data;
  },
  getVideoTelemetry: async (params = {}) => {
    const res = await apiClient.get('/admin/watch-sessions/video-telemetry/', { params });
    return res.data;
  },
  getVideoViewers: async (videoTaskId) => {
    const res = await apiClient.get('/admin/watch-sessions/video-viewers/', {
      params: { video_task_id: videoTaskId },
    });
    return res.data;
  },

  // Users
  getUsers: async (params = {}) => {
    const res = await apiClient.get('/admin/users/', { params });
    return res.data;
  },
  adjustUserBalance: async (id, data) => {
    const res = await apiClient.post(`/admin/users/${id}/adjust-balance/`, data);
    return res.data;
  },
  toggleUserStatus: async (id) => {
    const res = await apiClient.post(`/admin/users/${id}/toggle-status/`);
    return res.data;
  },

  // Financial Ledger
  getWalletTransactions: async (params = {}) => {
    const res = await apiClient.get('/admin/wallet-transactions/', { params });
    return res.data;
  },

  // Gamification & Daily Streak Settings
  getStreakSettings: async () => {
    const res = await apiClient.get('/admin/gamification-settings/');
    return res.data;
  },
  updateStreakSettings: async (data) => {
    const res = await apiClient.put('/admin/gamification-settings/', data);
    return res.data;
  },

  // Daily Spin Wheel Configuration
  getSpinWheelSegments: async () => {
    const res = await apiClient.get('/admin/spin-wheel-segments/');
    return res.data;
  },
  createSpinWheelSegment: async (data) => {
    const res = await apiClient.post('/admin/spin-wheel-segments/', data);
    return res.data;
  },
  updateSpinWheelSegment: async (id, data) => {
    const res = await apiClient.put(`/admin/spin-wheel-segments/${id}/`, data);
    return res.data;
  },
  patchSpinWheelSegment: async (id, data) => {
    const res = await apiClient.patch(`/admin/spin-wheel-segments/${id}/`, data);
    return res.data;
  },
  deleteSpinWheelSegment: async (id) => {
    const res = await apiClient.delete(`/admin/spin-wheel-segments/${id}/`);
    return res.data;
  },
  resetSpinWheelDefaults: async () => {
    const res = await apiClient.post('/admin/spin-wheel-segments/reset_defaults/');
    return res.data;
  },

  // XP & Leveling Settings (Phase 1.3)
  getXPSettings: async () => {
    const res = await apiClient.get('/admin/xp-settings/');
    return res.data;
  },
  updateXPSettings: async (data) => {
    const res = await apiClient.put('/admin/xp-settings/', data);
    return res.data;
  },
  patchXPSettings: async (data) => {
    const res = await apiClient.patch('/admin/xp-settings/', data);
    return res.data;
  },

  // Badges & Achievements (Phase 1.3)
  getBadges: async () => {
    const res = await apiClient.get('/admin/badges/');
    return res.data;
  },
  createBadge: async (data) => {
    const res = await apiClient.post('/admin/badges/', data);
    return res.data;
  },
  updateBadge: async (id, data) => {
    const res = await apiClient.patch(`/admin/badges/${id}/`, data);
    return res.data;
  },
  deleteBadge: async (id) => {
    const res = await apiClient.delete(`/admin/badges/${id}/`);
    return res.data;
  },
  seedDefaultBadges: async () => {
    const res = await apiClient.post('/admin/badges/seed_defaults/');
    return res.data;
  },

  // Tokens & Security
  getTokens: async () => {
    const res = await apiClient.get('/admin/tokens/');
    return res.data;
  },
  blacklistToken: async (tokenId) => {
    const res = await apiClient.post('/admin/tokens/', { token_id: tokenId });
    return res.data;
  },

  // Campaigns & Advertising Platform (Phase 5.5)
  getCampaigns: async (params = {}) => {
    const res = await apiClient.get('/campaigns/', { params });
    return res.data;
  },
  createCampaign: async (data) => {
    const res = await apiClient.post('/campaigns/create/', data);
    return res.data;
  },
  getCampaignDetails: async (id) => {
    const res = await apiClient.get(`/campaigns/${id}/`);
    return res.data;
  },
  submitCampaignForReview: async (id) => {
    const res = await apiClient.post(`/campaigns/${id}/submit/`);
    return res.data;
  },
  approveCampaign: async (id) => {
    const res = await apiClient.post(`/campaigns/${id}/approve/`);
    return res.data;
  },
  rejectCampaign: async (id, reason = '') => {
    const res = await apiClient.post(`/campaigns/${id}/reject/`, { reason });
    return res.data;
  },
  pauseCampaign: async (id) => {
    const res = await apiClient.post(`/campaigns/${id}/pause/`);
    return res.data;
  },

  // Campaign Media Management (Phase 5.5 Step 2)
  getCampaignMedia: async (campaignId, params = {}) => {
    const res = await apiClient.get(`/campaigns/${campaignId}/media/`, { params });
    return res.data;
  },
  uploadCampaignMedia: async (campaignId, formData) => {
    const res = await apiClient.post(`/campaigns/${campaignId}/media/upload/`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return res.data;
  },
  updateCampaignMedia: async (id, data) => {
    const res = await apiClient.patch(`/campaign-media/${id}/`, data);
    return res.data;
  },
  disableCampaignMedia: async (id) => {
    const res = await apiClient.delete(`/campaign-media/${id}/`);
    return res.data;
  },
  restoreCampaignMedia: async (id) => {
    const res = await apiClient.post(`/campaign-media/${id}/restore/`);
    return res.data;
  },

  // Campaign Ad Placement Delivery (Phase 5.5 Step 3)
  getCampaignPlacements: async (campaignId, params = {}) => {
    const res = await apiClient.get(`/campaigns/${campaignId}/placements/`, { params });
    return res.data;
  },
  createCampaignPlacement: async (campaignId, data) => {
    const res = await apiClient.post(`/campaigns/${campaignId}/placements/`, data);
    return res.data;
  },
  getAllAdPlacements: async (params = {}) => {
    const res = await apiClient.get('/ad-placements/', { params });
    return res.data;
  },
  getAdPlacementDetails: async (id) => {
    const res = await apiClient.get(`/ad-placement/${id}/`);
    return res.data;
  },
  updateAdPlacement: async (id, data) => {
    const res = await apiClient.patch(`/ad-placement/${id}/`, data);
    return res.data;
  },
  disableAdPlacement: async (id) => {
    const res = await apiClient.delete(`/ad-placement/${id}/`);
    return res.data;
  },
  restoreAdPlacement: async (id) => {
    const res = await apiClient.post(`/ad-placement/${id}/restore/`);
    return res.data;
  },
  getActiveAdsByLocation: async (placementType, limit = 10) => {
    const res = await apiClient.get(`/ads/${placementType}/`, { params: { limit } });
    return res.data;
  },

  // Campaign Tracking & Analytics (Phase 5.5 Step 4)
  getCampaignAnalytics: async (campaignId) => {
    const res = await apiClient.get(`/campaigns/${campaignId}/analytics/`);
    return res.data;
  },
  getAdvertiserOverviewAnalytics: async () => {
    const res = await apiClient.get('/advertiser/analytics/');
    return res.data;
  },
};


