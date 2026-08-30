import React, { useState, useEffect } from 'react';
import {
  Megaphone,
  Plus,
  Search,
  CheckCircle,
  XCircle,
  PauseCircle,
  Filter,
  DollarSign,
  Clock,
  Layers,
  AlertCircle,
  RefreshCw,
  Image as ImageIcon,
  Video,
  FileText,
  Eye,
  Trash2,
  RotateCcw,
  Upload,
  Radio,
  PlayCircle,
} from 'lucide-react';
import { adminApi } from '../api/adminApi';

export function CampaignsPage() {
  // Main Navigation Submenus
  const [activeTab, setActiveTab] = useState('list'); // 'overview', 'list', 'media', 'pending_media', 'disabled_media'

  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeType, setActiveType] = useState('ALL');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [searchQuery, setSearchQuery] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  // Campaign Form State
  const [formData, setFormData] = useState({
    title: '',
    campaign_type: 'TASK',
    description: '',
    budget: '100.00',
  });

  // Media Management State
  const [selectedCampaignForMedia, setSelectedCampaignForMedia] = useState(null);
  const [campaignMediaList, setCampaignMediaList] = useState([]);
  const [loadingMedia, setLoadingMedia] = useState(false);
  const [mediaTypeFilter, setMediaTypeFilter] = useState('ALL');
  const [mediaStatusFilter, setMediaStatusFilter] = useState('ALL');
  const [isUploadMediaModalOpen, setIsUploadMediaModalOpen] = useState(false);
  const [previewMediaModal, setPreviewMediaModal] = useState(null);

  // Media Upload Form
  const [mediaUploadForm, setMediaUploadForm] = useState({
    campaignId: '',
    media_type: 'IMAGE',
    title: '',
    description: '',
    file: null,
  });

  // Advertisement Placements State (Phase 5.5 Step 3)
  const [adPlacements, setAdPlacements] = useState([]);
  const [loadingPlacements, setLoadingPlacements] = useState(false);
  const [placementTypeFilter, setPlacementTypeFilter] = useState('ALL');
  const [placementStatusFilter, setPlacementStatusFilter] = useState('ALL');
  const [isPlacementModalOpen, setIsPlacementModalOpen] = useState(false);
  const [readyMediaForPlacement, setReadyMediaForPlacement] = useState([]);
  const [placementForm, setPlacementForm] = useState({
    campaignId: '',
    media_id: '',
    placement_type: 'HOME_FEED',
    priority: 10,
    status: 'ACTIVE',
    start_date: '',
    end_date: '',
  });

  const loadCampaigns = async () => {
    try {
      setLoading(true);
      setError(null);
      const params = {};
      if (activeType !== 'ALL') params.type = activeType;
      if (statusFilter !== 'ALL') params.status = statusFilter;
      if (searchQuery.trim()) params.search = searchQuery.trim();

      const res = await adminApi.getCampaigns(params);
      setCampaigns(res.campaigns || res.results || []);
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to load campaigns catalog.');
    } finally {
      setLoading(false);
    }
  };

  const loadMediaForCampaign = async (campaignId) => {
    if (!campaignId) return;
    try {
      setLoadingMedia(true);
      const params = {};
      if (mediaTypeFilter !== 'ALL') params.type = mediaTypeFilter;
      if (mediaStatusFilter !== 'ALL') params.status = mediaStatusFilter;

      const res = await adminApi.getCampaignMedia(campaignId, params);
      setCampaignMediaList(res.media || res.results || []);
    } catch (err) {
      console.error('Failed to load campaign media:', err);
    } finally {
      setLoadingMedia(false);
    }
  };

  const loadAdPlacements = async () => {
    try {
      setLoadingPlacements(true);
      const params = {};
      if (placementTypeFilter !== 'ALL') params.type = placementTypeFilter;
      if (placementStatusFilter !== 'ALL') params.status = placementStatusFilter;

      const res = await adminApi.getAllAdPlacements(params);
      setAdPlacements(res.placements || res.results || []);
    } catch (err) {
      console.error('Failed to load ad placements:', err);
    } finally {
      setLoadingPlacements(false);
    }
  };

  const loadReadyMediaForPlacement = async (campaignId) => {
    if (!campaignId) {
      setReadyMediaForPlacement([]);
      return;
    }
    try {
      const res = await adminApi.getCampaignMedia(campaignId, { status: 'READY' });
      const ready = res.media || res.results || [];
      setReadyMediaForPlacement(ready);
      if (ready.length > 0) {
        setPlacementForm((prev) => ({ ...prev, media_id: ready[0].id }));
      } else {
        setPlacementForm((prev) => ({ ...prev, media_id: '' }));
      }
    } catch (err) {
      console.error('Failed to load ready media for placement:', err);
    }
  };

  useEffect(() => {
    loadCampaigns();
  }, [activeType, statusFilter]);

  useEffect(() => {
    if (activeTab === 'placements') {
      loadAdPlacements();
    }
  }, [activeTab, placementTypeFilter, placementStatusFilter]);

  useEffect(() => {
    if (campaigns.length > 0 && !selectedCampaignForMedia) {
      setSelectedCampaignForMedia(campaigns[0].id);
    }
  }, [campaigns]);

  useEffect(() => {
    if (selectedCampaignForMedia) {
      loadMediaForCampaign(selectedCampaignForMedia);
    }
  }, [selectedCampaignForMedia, mediaTypeFilter, mediaStatusFilter]);

  const handleSearchSubmit = (e) => {
    e.preventDefault();
    loadCampaigns();
  };

  const handleCreateCampaign = async (e) => {
    e.preventDefault();
    try {
      setSubmitting(true);
      await adminApi.createCampaign({
        ...formData,
        budget: parseFloat(formData.budget) || 0,
      });
      setIsModalOpen(false);
      setFormData({
        title: '',
        campaign_type: 'TASK',
        description: '',
        budget: '100.00',
      });
      await loadCampaigns();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to create campaign.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleApprove = async (id) => {
    if (!window.confirm('Approve this campaign and transition status to ACTIVE?')) return;
    try {
      await adminApi.approveCampaign(id);
      await loadCampaigns();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to approve campaign.');
    }
  };

  const handleReject = async (id) => {
    const reason = window.prompt('Please enter a rejection reason (optional):');
    if (reason === null) return;
    try {
      await adminApi.rejectCampaign(id, reason);
      await loadCampaigns();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to reject campaign.');
    }
  };

  const handlePause = async (id) => {
    if (!window.confirm('Pause this active campaign?')) return;
    try {
      await adminApi.pauseCampaign(id);
      await loadCampaigns();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to pause campaign.');
    }
  };

  // Media Actions
  const handleUploadMedia = async (e) => {
    e.preventDefault();
    if (!mediaUploadForm.file) {
      alert('Please select a file to upload.');
      return;
    }
    const targetCampaignId = mediaUploadForm.campaignId || selectedCampaignForMedia;
    if (!targetCampaignId) {
      alert('Please select a campaign.');
      return;
    }

    try {
      setSubmitting(true);
      const formDataObj = new FormData();
      formDataObj.append('file', mediaUploadForm.file);
      formDataObj.append('media_type', mediaUploadForm.media_type);
      formDataObj.append('title', mediaUploadForm.title);
      formDataObj.append('description', mediaUploadForm.description);

      await adminApi.uploadCampaignMedia(targetCampaignId, formDataObj);
      setIsUploadMediaModalOpen(false);
      setMediaUploadForm({
        campaignId: '',
        media_type: 'IMAGE',
        title: '',
        description: '',
        file: null,
      });
      await loadMediaForCampaign(targetCampaignId);
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to upload campaign media.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDisableMedia = async (mediaId) => {
    if (!window.confirm('Disable this media asset? It will no longer be served in campaigns.')) return;
    try {
      await adminApi.disableCampaignMedia(mediaId);
      await loadMediaForCampaign(selectedCampaignForMedia);
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to disable media.');
    }
  };

  const handleRestoreMedia = async (mediaId) => {
    try {
      await adminApi.restoreCampaignMedia(mediaId);
      await loadMediaForCampaign(selectedCampaignForMedia);
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to restore media.');
    }
  };

  // Placement Action Handlers (Phase 5.5 Step 3)
  const handleCreatePlacement = async (e) => {
    e.preventDefault();
    if (!placementForm.campaignId) {
      alert('Please select a campaign.');
      return;
    }
    if (!placementForm.media_id) {
      alert('Please select an active media asset.');
      return;
    }

    try {
      setSubmitting(true);
      const payload = {
        media_id: placementForm.media_id,
        placement_type: placementForm.placement_type,
        priority: parseInt(placementForm.priority, 10) || 10,
        status: placementForm.status,
      };
      if (placementForm.start_date) payload.start_date = new Date(placementForm.start_date).toISOString();
      if (placementForm.end_date) payload.end_date = new Date(placementForm.end_date).toISOString();

      await adminApi.createCampaignPlacement(placementForm.campaignId, payload);
      setIsPlacementModalOpen(false);
      setPlacementForm({
        campaignId: '',
        media_id: '',
        placement_type: 'HOME_FEED',
        priority: 10,
        status: 'ACTIVE',
        start_date: '',
        end_date: '',
      });
      await loadAdPlacements();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to create advertisement placement.');
    } finally {
      setSubmitting(false);
    }
  };

  const handleActivatePlacement = async (id) => {
    try {
      await adminApi.updateAdPlacement(id, { status: 'ACTIVE' });
      await loadAdPlacements();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to activate placement.');
    }
  };

  const handlePausePlacement = async (id) => {
    try {
      await adminApi.updateAdPlacement(id, { status: 'PAUSED' });
      await loadAdPlacements();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to pause placement.');
    }
  };

  const handleDisablePlacement = async (id) => {
    if (!window.confirm('Disable this ad placement? It will stop being delivered on user surfaces.')) return;
    try {
      await adminApi.disableAdPlacement(id);
      await loadAdPlacements();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to disable placement.');
    }
  };

  const handleRestorePlacement = async (id) => {
    try {
      await adminApi.restoreAdPlacement(id);
      await loadAdPlacements();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to restore placement.');
    }
  };

  const getStatusBadge = (status) => {
    switch (status) {
      case 'ACTIVE':
        return <span className="badge badge-success">Active</span>;
      case 'PENDING_REVIEW':
        return <span className="badge badge-warning">Pending Review</span>;
      case 'DRAFT':
        return <span className="badge badge-secondary">Draft</span>;
      case 'PAUSED':
        return <span className="badge badge-neutral">Paused</span>;
      case 'COMPLETED':
        return <span className="badge badge-primary">Completed</span>;
      case 'REJECTED':
      case 'DISABLED':
      case 'FAILED':
        return <span className="badge badge-danger">{status}</span>;
      case 'READY':
        return <span className="badge badge-success">Ready</span>;
      default:
        return <span className="badge badge-secondary">{status}</span>;
    }
  };

  return (
    <div style={{ padding: '24px', maxWidth: '1400px', margin: '0 auto' }}>
      {/* Header */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--text-primary)', display: 'flex', alignItems: 'center', gap: '10px' }}>
            <Megaphone size={28} color="var(--primary-color)" />
            Campaign & Advertising Platform
          </h1>
          <p style={{ fontSize: '14px', color: 'var(--text-secondary)', marginTop: '4px' }}>
            Manage task campaigns, advertising creatives, media assets, reviews, and budgets.
          </p>
        </div>

        <div style={{ display: 'flex', gap: '12px' }}>
          <button
            onClick={() => {
              const campId = selectedCampaignForMedia || (campaigns[0]?.id || '');
              setPlacementForm((prev) => ({ ...prev, campaignId: campId }));
              loadReadyMediaForPlacement(campId);
              setIsPlacementModalOpen(true);
            }}
            className="btn btn-secondary"
            style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
          >
            <Radio size={18} />
            Assign Ad Placement
          </button>

          <button
            onClick={() => {
              setMediaUploadForm((prev) => ({ ...prev, campaignId: selectedCampaignForMedia || (campaigns[0]?.id || '') }));
              setIsUploadMediaModalOpen(true);
            }}
            className="btn btn-secondary"
            style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
          >
            <Upload size={18} />
            Upload Media
          </button>

          <button
            onClick={() => setIsModalOpen(true)}
            className="btn btn-primary"
            style={{ display: 'flex', alignItems: 'center', gap: '8px' }}
          >
            <Plus size={18} />
            Create Campaign
          </button>
        </div>
      </div>

      {/* Submenu Navigation Tabs */}
      <div style={{ display: 'flex', gap: '8px', borderBottom: '1px solid var(--border-color)', marginBottom: '24px', overflowX: 'auto' }}>
        {[
          { key: 'overview', label: 'Campaign Overview', icon: Layers },
          { key: 'list', label: 'Campaign List', icon: FileText },
          { key: 'media', label: 'Campaign Media', icon: ImageIcon },
          { key: 'placements', label: 'Ad Placements', icon: Radio },
          { key: 'pending_media', label: 'Pending Media Review', icon: Clock },
          { key: 'disabled_media', label: 'Disabled Media', icon: XCircle },
        ].map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.key;
          return (
            <button
              key={tab.key}
              onClick={() => {
                setActiveTab(tab.key);
                if (tab.key === 'pending_media') {
                  setMediaStatusFilter('PROCESSING');
                } else if (tab.key === 'disabled_media') {
                  setMediaStatusFilter('DISABLED');
                } else {
                  setMediaStatusFilter('ALL');
                }
              }}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '8px',
                padding: '12px 18px',
                background: 'none',
                border: 'none',
                borderBottom: isActive ? '2px solid var(--primary-color)' : '2px solid transparent',
                color: isActive ? 'var(--primary-color)' : 'var(--text-secondary)',
                fontWeight: isActive ? '700' : '500',
                cursor: 'pointer',
                fontSize: '14px',
              }}
            >
              <Icon size={16} />
              {tab.label}
            </button>
          );
        })}
      </div>

      {/* Overview Tab */}
      {activeTab === 'overview' && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '16px', marginBottom: '24px' }}>
          <div className="card" style={{ padding: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: '600' }}>TOTAL CAMPAIGNS</span>
              <Layers size={20} color="var(--primary-color)" />
            </div>
            <div style={{ fontSize: '28px', fontWeight: '800', marginTop: '12px' }}>{campaigns.length}</div>
          </div>

          <div className="card" style={{ padding: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: '600' }}>ACTIVE CAMPAIGNS</span>
              <CheckCircle size={20} color="#10b981" />
            </div>
            <div style={{ fontSize: '28px', fontWeight: '800', marginTop: '12px', color: '#10b981' }}>
              {campaigns.filter((c) => c.status === 'ACTIVE').length}
            </div>
          </div>

          <div className="card" style={{ padding: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: '600' }}>PENDING REVIEWS</span>
              <Clock size={20} color="#f59e0b" />
            </div>
            <div style={{ fontSize: '28px', fontWeight: '800', marginTop: '12px', color: '#f59e0b' }}>
              {campaigns.filter((c) => c.status === 'PENDING_REVIEW').length}
            </div>
          </div>

          <div className="card" style={{ padding: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: '600' }}>TOTAL BUDGET POOL</span>
              <DollarSign size={20} color="#6366f1" />
            </div>
            <div style={{ fontSize: '28px', fontWeight: '800', marginTop: '12px' }}>
              ${campaigns.reduce((sum, c) => sum + (parseFloat(c.budget) || 0), 0).toFixed(2)}
            </div>
          </div>
        </div>
      )}

      {/* Campaigns List Tab */}
      {activeTab === 'list' && (
        <>
          {/* Filter Toolbar */}
          <div className="card" style={{ padding: '16px', marginBottom: '20px', display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'center' }}>
            {/* Search Input */}
            <form onSubmit={handleSearchSubmit} style={{ flex: '1', minWidth: '240px', display: 'flex', gap: '8px' }}>
              <div style={{ position: 'relative', width: '100%' }}>
                <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-secondary)' }} />
                <input
                  type="text"
                  placeholder="Search campaigns by title, description, or owner..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  style={{
                    width: '100%',
                    padding: '10px 12px 10px 38px',
                    borderRadius: '8px',
                    border: '1px solid var(--border-color)',
                    background: 'var(--bg-primary)',
                    color: 'var(--text-primary)',
                  }}
                />
              </div>
              <button type="submit" className="btn btn-secondary">Search</button>
            </form>

            {/* Type Selector */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: '600' }}>Type:</span>
              <select
                value={activeType}
                onChange={(e) => setActiveType(e.target.value)}
                style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
              >
                <option value="ALL">All Types</option>
                <option value="TASK">Task Campaign</option>
                <option value="ADVERTISEMENT">Advertisement</option>
                <option value="SPONSORED_CONTENT">Sponsored Content</option>
              </select>
            </div>

            {/* Status Selector */}
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: '600' }}>Status:</span>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
              >
                <option value="ALL">All Statuses</option>
                <option value="DRAFT">Draft</option>
                <option value="PENDING_REVIEW">Pending Review</option>
                <option value="ACTIVE">Active</option>
                <option value="PAUSED">Paused</option>
                <option value="COMPLETED">Completed</option>
                <option value="REJECTED">Rejected</option>
              </select>
            </div>
          </div>

          {/* Data Table */}
          <div className="card" style={{ overflow: 'hidden' }}>
            {loading ? (
              <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
                <RefreshCw size={24} className="spin" style={{ margin: '0 auto 12px' }} />
                Loading campaigns catalog...
              </div>
            ) : campaigns.length === 0 ? (
              <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
                No campaigns match the selected filters.
              </div>
            ) : (
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
                <thead>
                  <tr style={{ background: 'var(--bg-primary)', borderBottom: '1px solid var(--border-color)' }}>
                    <th style={{ padding: '14px 16px', fontSize: '12px', color: 'var(--text-secondary)' }}>CAMPAIGN</th>
                    <th style={{ padding: '14px 16px', fontSize: '12px', color: 'var(--text-secondary)' }}>TYPE</th>
                    <th style={{ padding: '14px 16px', fontSize: '12px', color: 'var(--text-secondary)' }}>STATUS</th>
                    <th style={{ padding: '14px 16px', fontSize: '12px', color: 'var(--text-secondary)' }}>BUDGET</th>
                    <th style={{ padding: '14px 16px', fontSize: '12px', color: 'var(--text-secondary)' }}>OWNER</th>
                    <th style={{ padding: '14px 16px', fontSize: '12px', color: 'var(--text-secondary)' }}>CREATED</th>
                    <th style={{ padding: '14px 16px', fontSize: '12px', color: 'var(--text-secondary)', textAlign: 'right' }}>ACTIONS</th>
                  </tr>
                </thead>
                <tbody>
                  {campaigns.map((c) => (
                    <tr key={c.id} style={{ borderBottom: '1px solid var(--border-color)' }}>
                      <td style={{ padding: '16px' }}>
                        <div style={{ fontWeight: '700', color: 'var(--text-primary)' }}>{c.title}</div>
                        {c.description && <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>{c.description}</div>}
                      </td>
                      <td style={{ padding: '16px', fontSize: '13px' }}>{c.campaign_type_display || c.campaign_type}</td>
                      <td style={{ padding: '16px' }}>{getStatusBadge(c.status)}</td>
                      <td style={{ padding: '16px', fontWeight: '700' }}>${parseFloat(c.budget).toFixed(2)}</td>
                      <td style={{ padding: '16px', fontSize: '13px' }}>{c.owner_details?.email || 'System'}</td>
                      <td style={{ padding: '16px', fontSize: '13px', color: 'var(--text-secondary)' }}>
                        {new Date(c.created_at).toLocaleDateString()}
                      </td>
                      <td style={{ padding: '16px', textAlign: 'right' }}>
                        <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                          <button
                            onClick={() => {
                              setSelectedCampaignForMedia(c.id);
                              setActiveTab('media');
                            }}
                            className="btn btn-secondary btn-sm"
                            title="View Attached Media Assets"
                          >
                            <ImageIcon size={14} />
                            Media
                          </button>

                          {c.status === 'PENDING_REVIEW' && (
                            <>
                              <button onClick={() => handleApprove(c.id)} className="btn btn-success btn-sm" title="Approve Campaign">
                                <CheckCircle size={14} />
                                Approve
                              </button>
                              <button onClick={() => handleReject(c.id)} className="btn btn-danger btn-sm" title="Reject Campaign">
                                <XCircle size={14} />
                                Reject
                              </button>
                            </>
                          )}

                          {c.status === 'ACTIVE' && (
                            <button onClick={() => handlePause(c.id)} className="btn btn-secondary btn-sm" title="Pause Campaign">
                              <PauseCircle size={14} />
                              Pause
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </>
      )}

      {/* Campaign Media Tab / Views */}
      {(activeTab === 'media' || activeTab === 'pending_media' || activeTab === 'disabled_media') && (
        <div>
          {/* Campaign Selector Bar */}
          <div className="card" style={{ padding: '16px', marginBottom: '20px', display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'center' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px', flex: '1', minWidth: '260px' }}>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: '600' }}>Select Campaign:</span>
              <select
                value={selectedCampaignForMedia || ''}
                onChange={(e) => setSelectedCampaignForMedia(e.target.value)}
                style={{ flex: 1, padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
              >
                {campaigns.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.title} ({c.campaign_type_display})
                  </option>
                ))}
              </select>
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: '600' }}>Media Type:</span>
              <select
                value={mediaTypeFilter}
                onChange={(e) => setMediaTypeFilter(e.target.value)}
                style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
              >
                <option value="ALL">All Media Types</option>
                <option value="VIDEO">Videos</option>
                <option value="BANNER">Banners</option>
                <option value="IMAGE">Images</option>
              </select>
            </div>
          </div>

          {/* Media Grid / Assets */}
          {loadingMedia ? (
            <div className="card" style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
              <RefreshCw size={24} className="spin" style={{ margin: '0 auto 12px' }} />
              Loading campaign media assets...
            </div>
          ) : campaignMediaList.length === 0 ? (
            <div className="card" style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
              <ImageIcon size={32} style={{ margin: '0 auto 12px', opacity: 0.5 }} />
              <div>No media creatives attached to this campaign.</div>
              <button
                onClick={() => {
                  setMediaUploadForm((prev) => ({ ...prev, campaignId: selectedCampaignForMedia }));
                  setIsUploadMediaModalOpen(true);
                }}
                className="btn btn-primary"
                style={{ marginTop: '16px' }}
              >
                <Upload size={16} /> Upload First Creative
              </button>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '20px' }}>
              {campaignMediaList.map((media) => (
                <div key={media.id} className="card" style={{ overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
                  {/* Thumbnail / Preview Area */}
                  <div
                    style={{
                      height: '180px',
                      background: 'var(--bg-primary)',
                      position: 'relative',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      borderBottom: '1px solid var(--border-color)',
                      overflow: 'hidden',
                    }}
                  >
                    {media.media_type === 'VIDEO' ? (
                      <div style={{ textAlign: 'center' }}>
                        <Video size={48} color="var(--primary-color)" />
                        <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '6px' }}>Video Creative ({media.duration_seconds || 0}s)</div>
                      </div>
                    ) : media.file_url ? (
                      <img
                        src={media.file_url}
                        alt={media.title}
                        style={{ width: '100%', height: '100%', objectFit: 'contain' }}
                      />
                    ) : (
                      <ImageIcon size={48} color="var(--text-secondary)" />
                    )}

                    <div style={{ position: 'absolute', top: '10px', right: '10px' }}>
                      {getStatusBadge(media.status)}
                    </div>
                  </div>

                  {/* Body Details */}
                  <div style={{ padding: '16px', flex: 1, display: 'flex', flexDirection: 'column' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                      <h3 style={{ fontSize: '15px', fontWeight: '700', color: 'var(--text-primary)', margin: 0 }}>{media.title}</h3>
                      <span className="badge badge-secondary" style={{ fontSize: '11px' }}>{media.media_type_display}</span>
                    </div>

                    {media.description && (
                      <p style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '6px', flex: 1 }}>{media.description}</p>
                    )}

                    {/* Metadata specs */}
                    <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap', marginTop: '12px', fontSize: '11px', color: 'var(--text-secondary)' }}>
                      {media.width && media.height && (
                        <span style={{ padding: '2px 6px', background: 'var(--bg-primary)', borderRadius: '4px' }}>
                          {media.width}x{media.height}
                        </span>
                      )}
                      <span style={{ padding: '2px 6px', background: 'var(--bg-primary)', borderRadius: '4px' }}>
                        {media.file_size_formatted || `${media.file_size} B`}
                      </span>
                      <span style={{ padding: '2px 6px', background: 'var(--bg-primary)', borderRadius: '4px' }}>
                        {media.mime_type}
                      </span>
                    </div>

                    {/* Footer Actions */}
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '16px', paddingTop: '12px', borderTop: '1px solid var(--border-color)' }}>
                      <button
                        onClick={() => setPreviewMediaModal(media)}
                        className="btn btn-secondary btn-sm"
                        style={{ display: 'flex', alignItems: 'center', gap: '4px' }}
                      >
                        <Eye size={14} /> Preview
                      </button>

                      {media.status !== 'DISABLED' ? (
                        <button
                          onClick={() => handleDisableMedia(media.id)}
                          className="btn btn-danger btn-sm"
                          style={{ display: 'flex', alignItems: 'center', gap: '4px' }}
                        >
                          <Trash2 size={14} /> Disable
                        </button>
                      ) : (
                        <button
                          onClick={() => handleRestoreMedia(media.id)}
                          className="btn btn-success btn-sm"
                          style={{ display: 'flex', alignItems: 'center', gap: '4px' }}
                        >
                          <RotateCcw size={14} /> Restore
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Advertisement Placements Tab (Phase 5.5 Step 3) */}
      {activeTab === 'placements' && (
        <div>
          {/* Filter & Controls Bar */}
          <div className="card" style={{ padding: '16px', marginBottom: '20px', display: 'flex', gap: '16px', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', alignItems: 'center' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: '600' }}>Surface Location:</span>
                <select
                  value={placementTypeFilter}
                  onChange={(e) => setPlacementTypeFilter(e.target.value)}
                  style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                >
                  <option value="ALL">All Locations</option>
                  <option value="HOME_FEED">Home Feed</option>
                  <option value="HEADER">Header Banner</option>
                  <option value="FOOTER">Footer Banner</option>
                  <option value="POPUP">Popup Modal</option>
                  <option value="VIDEO_PREROLL">Video Pre-Roll</option>
                  <option value="TASK_FEED">Task Feed</option>
                </select>
              </div>

              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <span style={{ fontSize: '13px', color: 'var(--text-secondary)', fontWeight: '600' }}>Status:</span>
                <select
                  value={placementStatusFilter}
                  onChange={(e) => setPlacementStatusFilter(e.target.value)}
                  style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                >
                  <option value="ALL">All Statuses</option>
                  <option value="ACTIVE">Active</option>
                  <option value="PAUSED">Paused</option>
                  <option value="DRAFT">Draft</option>
                  <option value="DISABLED">Disabled</option>
                </select>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button onClick={loadAdPlacements} className="btn btn-secondary btn-sm" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <RefreshCw size={14} /> Refresh
              </button>
              <button
                onClick={() => {
                  const campId = selectedCampaignForMedia || (campaigns[0]?.id || '');
                  setPlacementForm((prev) => ({ ...prev, campaignId: campId }));
                  loadReadyMediaForPlacement(campId);
                  setIsPlacementModalOpen(true);
                }}
                className="btn btn-primary btn-sm"
                style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
              >
                <Plus size={14} /> New Placement
              </button>
            </div>
          </div>

          {/* Placements List */}
          <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
            {loadingPlacements ? (
              <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
                <RefreshCw size={24} className="spin" style={{ margin: '0 auto 12px' }} />
                Loading advertisement placements...
              </div>
            ) : adPlacements.length === 0 ? (
              <div style={{ padding: '40px', textAlign: 'center', color: 'var(--text-secondary)' }}>
                <Radio size={32} style={{ margin: '0 auto 12px', opacity: 0.5 }} />
                <div>No advertisement placements found.</div>
                <button
                  onClick={() => {
                    const campId = selectedCampaignForMedia || (campaigns[0]?.id || '');
                    setPlacementForm((prev) => ({ ...prev, campaignId: campId }));
                    loadReadyMediaForPlacement(campId);
                    setIsPlacementModalOpen(true);
                  }}
                  className="btn btn-primary"
                  style={{ marginTop: '16px' }}
                >
                  <Plus size={16} /> Assign First Placement
                </button>
              </div>
            ) : (
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '13px' }}>
                <thead>
                  <tr style={{ background: 'var(--bg-primary)', borderBottom: '1px solid var(--border-color)', color: 'var(--text-secondary)', fontWeight: '600' }}>
                    <th style={{ padding: '14px 16px' }}>Surface Placement</th>
                    <th style={{ padding: '14px 16px' }}>Priority</th>
                    <th style={{ padding: '14px 16px' }}>Creative Asset</th>
                    <th style={{ padding: '14px 16px' }}>Campaign</th>
                    <th style={{ padding: '14px 16px' }}>Validity Window</th>
                    <th style={{ padding: '14px 16px' }}>Status</th>
                    <th style={{ padding: '14px 16px', textAlign: 'right' }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {adPlacements.map((p) => (
                    <tr key={p.id} style={{ borderBottom: '1px solid var(--border-color)' }}>
                      <td style={{ padding: '14px 16px' }}>
                        <span className="badge badge-primary" style={{ fontWeight: '700' }}>
                          {p.placement_type_display || p.placement_type}
                        </span>
                      </td>
                      <td style={{ padding: '14px 16px' }}>
                        <span style={{ fontWeight: '700', padding: '3px 8px', background: 'var(--bg-primary)', borderRadius: '6px' }}>
                          P-{p.priority}
                        </span>
                      </td>
                      <td style={{ padding: '14px 16px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                          {p.media_details?.file_url ? (
                            <img
                              src={p.media_details.file_url}
                              alt=""
                              style={{ width: '36px', height: '36px', borderRadius: '6px', objectFit: 'cover' }}
                            />
                          ) : (
                            <div style={{ width: '36px', height: '36px', borderRadius: '6px', background: 'var(--bg-primary)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                              <ImageIcon size={18} color="var(--text-secondary)" />
                            </div>
                          )}
                          <div>
                            <div style={{ fontWeight: '600', color: 'var(--text-primary)' }}>{p.media_details?.title || 'Creative Asset'}</div>
                            <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>{p.media_details?.media_type_display || 'Media'}</div>
                          </div>
                        </div>
                      </td>
                      <td style={{ padding: '14px 16px' }}>
                        <div style={{ fontWeight: '600' }}>{p.campaign_title}</div>
                        <div style={{ fontSize: '11px', color: 'var(--text-secondary)' }}>Status: {p.campaign_status}</div>
                      </td>
                      <td style={{ padding: '14px 16px', color: 'var(--text-secondary)', fontSize: '12px' }}>
                        {p.start_date || p.end_date ? (
                          <>
                            {p.start_date ? new Date(p.start_date).toLocaleDateString() : 'Now'} - {p.end_date ? new Date(p.end_date).toLocaleDateString() : 'Ongoing'}
                          </>
                        ) : (
                          'Continuous / Always Active'
                        )}
                      </td>
                      <td style={{ padding: '14px 16px' }}>
                        {getStatusBadge(p.status)}
                      </td>
                      <td style={{ padding: '14px 16px', textAlign: 'right' }}>
                        <div style={{ display: 'flex', gap: '6px', justifyContent: 'flex-end' }}>
                          {p.status === 'ACTIVE' ? (
                            <button onClick={() => handlePausePlacement(p.id)} className="btn btn-secondary btn-sm" title="Pause Placement">
                              <PauseCircle size={14} /> Pause
                            </button>
                          ) : p.status === 'PAUSED' || p.status === 'DRAFT' ? (
                            <button onClick={() => handleActivatePlacement(p.id)} className="btn btn-success btn-sm" title="Activate Placement">
                              <PlayCircle size={14} /> Activate
                            </button>
                          ) : null}

                          {p.status !== 'DISABLED' ? (
                            <button onClick={() => handleDisablePlacement(p.id)} className="btn btn-danger btn-sm" title="Disable Placement">
                              <Trash2 size={14} />
                            </button>
                          ) : (
                            <button onClick={() => handleRestorePlacement(p.id)} className="btn btn-success btn-sm" title="Restore Placement">
                              <RotateCcw size={14} />
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      )}

      {/* Create Ad Placement Modal */}
      {isPlacementModalOpen && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="card" style={{ width: '560px', maxWidth: '90%', padding: '24px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '16px' }}>Assign Advertisement Placement</h2>
            <form onSubmit={handleCreatePlacement}>
              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Target Campaign</label>
                <select
                  value={placementForm.campaignId}
                  onChange={(e) => {
                    const campId = e.target.value;
                    setPlacementForm({ ...placementForm, campaignId: campId });
                    loadReadyMediaForPlacement(campId);
                  }}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                >
                  {campaigns.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.title} ({c.campaign_type_display} - {c.status})
                    </option>
                  ))}
                </select>
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Select Ready Creative Asset</label>
                {readyMediaForPlacement.length === 0 ? (
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)', padding: '10px', background: 'var(--bg-primary)', borderRadius: '8px' }}>
                    No READY media found for this campaign. Upload and review media first.
                  </div>
                ) : (
                  <select
                    value={placementForm.media_id}
                    onChange={(e) => setPlacementForm({ ...placementForm, media_id: e.target.value })}
                    style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                  >
                    {readyMediaForPlacement.map((m) => (
                      <option key={m.id} value={m.id}>
                        {m.title} ({m.media_type_display} - {m.file_size_formatted || `${m.file_size} B`})
                      </option>
                    ))}
                  </select>
                )}
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px', marginBottom: '14px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Surface Location</label>
                  <select
                    value={placementForm.placement_type}
                    onChange={(e) => setPlacementForm({ ...placementForm, placement_type: e.target.value })}
                    style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                  >
                    <option value="HOME_FEED">Home Feed</option>
                    <option value="HEADER">Header Banner</option>
                    <option value="FOOTER">Footer Banner</option>
                    <option value="POPUP">Popup Modal</option>
                    <option value="VIDEO_PREROLL">Video Pre-Roll</option>
                    <option value="TASK_FEED">Task Feed</option>
                  </select>
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Priority (Weight)</label>
                  <input
                    type="number"
                    min="1"
                    max="1000"
                    value={placementForm.priority}
                    onChange={(e) => setPlacementForm({ ...placementForm, priority: e.target.value })}
                    style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                  />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px', marginBottom: '14px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Start Date (Optional)</label>
                  <input
                    type="datetime-local"
                    value={placementForm.start_date}
                    onChange={(e) => setPlacementForm({ ...placementForm, start_date: e.target.value })}
                    style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                  />
                </div>

                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>End Date (Optional)</label>
                  <input
                    type="datetime-local"
                    value={placementForm.end_date}
                    onChange={(e) => setPlacementForm({ ...placementForm, end_date: e.target.value })}
                    style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                  />
                </div>
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Initial Status</label>
                <select
                  value={placementForm.status}
                  onChange={(e) => setPlacementForm({ ...placementForm, status: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                >
                  <option value="ACTIVE">Active (Deliver immediately)</option>
                  <option value="DRAFT">Draft</option>
                  <option value="PAUSED">Paused</option>
                </select>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                <button type="button" onClick={() => setIsPlacementModalOpen(false)} className="btn btn-secondary">Cancel</button>
                <button type="submit" disabled={submitting || readyMediaForPlacement.length === 0} className="btn btn-primary">
                  {submitting ? 'Assigning...' : 'Assign Placement'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Create Campaign Modal */}
      {isModalOpen && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="card" style={{ width: '500px', maxWidth: '90%', padding: '24px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '16px' }}>Create New Campaign</h2>
            <form onSubmit={handleCreateCampaign}>
              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Campaign Title</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Summer Video Promo 2026"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                />
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Campaign Type</label>
                <select
                  value={formData.campaign_type}
                  onChange={(e) => setFormData({ ...formData, campaign_type: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                >
                  <option value="TASK">Task Campaign</option>
                  <option value="ADVERTISEMENT">Advertisement Campaign</option>
                  <option value="SPONSORED_CONTENT">Sponsored Content</option>
                </select>
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Budget Pool (USD)</label>
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  required
                  value={formData.budget}
                  onChange={(e) => setFormData({ ...formData, budget: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                />
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Description</label>
                <textarea
                  rows="3"
                  placeholder="Campaign objectives and requirements..."
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                <button type="button" onClick={() => setIsModalOpen(false)} className="btn btn-secondary">Cancel</button>
                <button type="submit" disabled={submitting} className="btn btn-primary">
                  {submitting ? 'Creating...' : 'Create Draft Campaign'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Upload Media Modal */}
      {isUploadMediaModalOpen && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="card" style={{ width: '520px', maxWidth: '90%', padding: '24px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '16px' }}>Upload Campaign Media Creative</h2>
            <form onSubmit={handleUploadMedia}>
              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Target Campaign</label>
                <select
                  value={mediaUploadForm.campaignId}
                  onChange={(e) => setMediaUploadForm({ ...mediaUploadForm, campaignId: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                >
                  {campaigns.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.title} ({c.campaign_type_display})
                    </option>
                  ))}
                </select>
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Media Asset Title</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. 728x90 Header Banner"
                  value={mediaUploadForm.title}
                  onChange={(e) => setMediaUploadForm({ ...mediaUploadForm, title: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                />
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Asset Category</label>
                <select
                  value={mediaUploadForm.media_type}
                  onChange={(e) => setMediaUploadForm({ ...mediaUploadForm, media_type: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                >
                  <option value="IMAGE">Image Asset (jpg, png, webp - max 10MB)</option>
                  <option value="BANNER">Banner Asset (jpg, png, webp - max 10MB)</option>
                  <option value="VIDEO">Video Asset (mp4, mov - max 500MB)</option>
                </select>
              </div>

              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Select File</label>
                <input
                  type="file"
                  required
                  accept={mediaUploadForm.media_type === 'VIDEO' ? 'video/mp4,video/quicktime' : 'image/jpeg,image/png,image/webp'}
                  onChange={(e) => setMediaUploadForm({ ...mediaUploadForm, file: e.target.files[0] })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                />
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Description</label>
                <textarea
                  rows="2"
                  placeholder="Creative specifications or placement instructions..."
                  value={mediaUploadForm.description}
                  onChange={(e) => setMediaUploadForm({ ...mediaUploadForm, description: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                <button type="button" onClick={() => setIsUploadMediaModalOpen(false)} className="btn btn-secondary">Cancel</button>
                <button type="submit" disabled={submitting} className="btn btn-primary">
                  {submitting ? 'Uploading...' : 'Upload Asset'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Preview Modal */}
      {previewMediaModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.7)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="card" style={{ width: '700px', maxWidth: '90%', padding: '24px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <h2 style={{ fontSize: '18px', fontWeight: '800', margin: 0 }}>{previewMediaModal.title}</h2>
              <button onClick={() => setPreviewMediaModal(null)} className="btn btn-secondary btn-sm">Close</button>
            </div>

            <div style={{ maxHeight: '400px', background: 'var(--bg-primary)', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: '8px', overflow: 'hidden', marginBottom: '16px' }}>
              {previewMediaModal.media_type === 'VIDEO' ? (
                <video controls src={previewMediaModal.file_url} style={{ maxWidth: '100%', maxHeight: '380px' }} />
              ) : (
                <img src={previewMediaModal.file_url} alt={previewMediaModal.title} style={{ maxWidth: '100%', maxHeight: '380px', objectFit: 'contain' }} />
              )}
            </div>

            <div style={{ fontSize: '13px', color: 'var(--text-secondary)', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px' }}>
              <div><strong>Format:</strong> {previewMediaModal.mime_type}</div>
              <div><strong>Size:</strong> {previewMediaModal.file_size_formatted || previewMediaModal.file_size}</div>
              <div><strong>Dimensions:</strong> {previewMediaModal.width && previewMediaModal.height ? `${previewMediaModal.width}x${previewMediaModal.height}` : 'N/A'}</div>
              <div><strong>Status:</strong> {previewMediaModal.status}</div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
