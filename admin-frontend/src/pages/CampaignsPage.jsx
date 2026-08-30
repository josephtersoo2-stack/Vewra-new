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
  BarChart2,
  TrendingUp,
  MousePointer,
  Activity,
  CreditCard,
  Wallet,
  Receipt,
  Download,
  ShieldAlert,
  ArrowUpRight,
  Printer,
  Sparkles,
} from 'lucide-react';
import { adminApi } from '../api/adminApi';

export function CampaignsPage() {
  // Main Navigation Submenus
  const [activeTab, setActiveTab] = useState('list'); // 'overview', 'list', 'media', 'placements', 'analytics', 'billing', 'reports', 'invoices'

  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeType, setActiveType] = useState('ALL');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [searchQuery, setSearchQuery] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  // Campaign Analytics State (Phase 5.5 Step 4)
  const [selectedCampaignForAnalytics, setSelectedCampaignForAnalytics] = useState('ALL');
  const [analyticsData, setAnalyticsData] = useState(null);
  const [loadingAnalytics, setLoadingAnalytics] = useState(false);

  // Advertiser Billing & Spend State (Phase 5.5 Step 5)
  const [walletData, setWalletData] = useState(null);
  const [billingHistory, setBillingHistory] = useState([]);
  const [selectedCampaignForSpending, setSelectedCampaignForSpending] = useState('ALL');
  const [campaignSpendingData, setCampaignSpendingData] = useState(null);
  const [reportsData, setReportsData] = useState(null);
  const [loadingBilling, setLoadingBilling] = useState(false);
  const [loadingReports, setLoadingReports] = useState(false);
  const [isFundWalletModalOpen, setIsFundWalletModalOpen] = useState(false);
  const [fundAmount, setFundAmount] = useState('50.00');
  const [submittingFund, setSubmittingFund] = useState(false);
  const [isConfigureBudgetModalOpen, setIsConfigureBudgetModalOpen] = useState(false);
  const [budgetConfigForm, setBudgetConfigForm] = useState({
    campaignId: '',
    daily_budget: '20.00',
    total_budget: '100.00',
    cpm_rate: '2.00',
    cpc_rate: '0.10',
    cpv_rate: '0.05',
    status: 'ACTIVE',
  });
  const [submittingBudgetConfig, setSubmittingBudgetConfig] = useState(false);
  const [exportingCsv, setExportingCsv] = useState(false);

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

  const loadAnalytics = async () => {
    try {
      setLoadingAnalytics(true);
      if (selectedCampaignForAnalytics === 'ALL') {
        const res = await adminApi.getAdvertiserOverviewAnalytics();
        setAnalyticsData(res);
      } else {
        const res = await adminApi.getCampaignAnalytics(selectedCampaignForAnalytics);
        setAnalyticsData(res);
      }
    } catch (err) {
      console.error('Failed to load campaign analytics:', err);
    } finally {
      setLoadingAnalytics(false);
    }
  };

  const loadBillingData = async () => {
    try {
      setLoadingBilling(true);
      const [walletRes, historyRes] = await Promise.all([
        adminApi.getAdvertiserWallet().catch(() => null),
        adminApi.getBillingHistory({ limit: 50 }).catch(() => ({ charges: [] })),
      ]);
      if (walletRes) setWalletData(walletRes);
      if (historyRes) setBillingHistory(historyRes.charges || historyRes.results || []);

      if (selectedCampaignForSpending && selectedCampaignForSpending !== 'ALL') {
        const spendingRes = await adminApi.getCampaignSpending(selectedCampaignForSpending).catch(() => null);
        if (spendingRes) setCampaignSpendingData(spendingRes);
      } else if (campaigns.length > 0) {
        const firstCampId = campaigns[0].id;
        const spendingRes = await adminApi.getCampaignSpending(firstCampId).catch(() => null);
        if (spendingRes) {
          setCampaignSpendingData(spendingRes);
        }
      }
    } catch (err) {
      console.error('Failed to load billing data:', err);
    } finally {
      setLoadingBilling(false);
    }
  };

  const loadReportsData = async () => {
    try {
      setLoadingReports(true);
      const params = {};
      if (selectedCampaignForSpending && selectedCampaignForSpending !== 'ALL') {
        params.campaign_id = selectedCampaignForSpending;
      }
      const res = await adminApi.getAdvertiserReports(params);
      setReportsData(res);
    } catch (err) {
      console.error('Failed to load reports data:', err);
    } finally {
      setLoadingReports(false);
    }
  };

  useEffect(() => {
    if (activeTab === 'analytics') {
      loadAnalytics();
    } else if (activeTab === 'billing') {
      loadBillingData();
    } else if (activeTab === 'reports' || activeTab === 'invoices') {
      loadReportsData();
      if (!walletData) loadBillingData();
    }
  }, [activeTab, selectedCampaignForAnalytics, selectedCampaignForSpending]);

  const handleFundWallet = async (e) => {
    e.preventDefault();
    try {
      setSubmittingFund(true);
      const amount = parseFloat(fundAmount);
      if (isNaN(amount) || amount <= 0) {
        alert('Please enter a valid positive deposit amount.');
        return;
      }
      await adminApi.fundAdvertiserWallet(amount);
      setIsFundWalletModalOpen(false);
      setFundAmount('50.00');
      await loadBillingData();
      alert(`Successfully deposited $${amount.toFixed(2)} into advertiser wallet!`);
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to deposit funds into wallet.');
    } finally {
      setSubmittingFund(false);
    }
  };

  const handleConfigureBudget = async (e) => {
    e.preventDefault();
    if (!budgetConfigForm.campaignId) {
      alert('Please select a campaign.');
      return;
    }
    try {
      setSubmittingBudgetConfig(true);
      await adminApi.configureCampaignBudget(budgetConfigForm.campaignId, {
        daily_budget: parseFloat(budgetConfigForm.daily_budget) || 0,
        total_budget: parseFloat(budgetConfigForm.total_budget) || 0,
        cpm_rate: parseFloat(budgetConfigForm.cpm_rate) || 2.0,
        cpc_rate: parseFloat(budgetConfigForm.cpc_rate) || 0.1,
        cpv_rate: parseFloat(budgetConfigForm.cpv_rate) || 0.05,
        status: budgetConfigForm.status,
      });
      setIsConfigureBudgetModalOpen(false);
      await loadBillingData();
      await loadCampaigns();
      alert('Campaign budget & pricing rates updated successfully!');
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to configure campaign budget.');
    } finally {
      setSubmittingBudgetConfig(false);
    }
  };

  const handleExportCsv = async () => {
    try {
      setExportingCsv(true);
      const params = {};
      if (selectedCampaignForSpending && selectedCampaignForSpending !== 'ALL') {
        params.campaign_id = selectedCampaignForSpending;
      }
      const blob = await adminApi.exportAdvertiserReportCsv(params);
      const url = window.URL.createObjectURL(new Blob([blob], { type: 'text/csv' }));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `vewra_advertiser_financial_report_${new Date().toISOString().split('T')[0]}.csv`);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      console.error(err);
      alert('Failed to export CSV report.');
    } finally {
      setExportingCsv(false);
    }
  };

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

        <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
          <button
            onClick={() => setIsFundWalletModalOpen(true)}
            className="btn btn-secondary"
            style={{ display: 'flex', alignItems: 'center', gap: '8px', border: '1px solid var(--primary-color)' }}
          >
            <Wallet size={18} color="var(--primary-color)" />
            Deposit Funds ({walletData ? `$${Number(walletData.balance).toFixed(2)}` : 'Wallet'})
          </button>

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
          { key: 'analytics', label: 'Analytics & Tracking', icon: BarChart2 },
          { key: 'billing', label: 'Billing & Spend', icon: DollarSign },
          { key: 'reports', label: 'Financial Reports', icon: TrendingUp },
          { key: 'invoices', label: 'Invoices & Receipts', icon: Receipt },
          { key: 'pending_media', label: 'Pending Review', icon: Clock },
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

      {/* Analytics & Measurement Foundation (Phase 5.5 Step 4) */}
      {activeTab === 'analytics' && (
        <div>
          {/* Analytics Toolbar */}
          <div className="card" style={{ padding: '16px 20px', marginBottom: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', flex: 1, minWidth: '280px' }}>
              <BarChart2 size={20} color="var(--primary-color)" />
              <label style={{ fontSize: '14px', fontWeight: '700', whiteSpace: 'nowrap' }}>Filter Analytics:</label>
              <select
                value={selectedCampaignForAnalytics}
                onChange={(e) => setSelectedCampaignForAnalytics(e.target.value)}
                style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)', fontSize: '13px', minWidth: '240px' }}
              >
                <option value="ALL">All Campaigns (Platform Overview)</option>
                {campaigns.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.title} ({c.campaign_type_display} - {c.status})
                  </option>
                ))}
              </select>
            </div>

            <button onClick={loadAnalytics} className="btn btn-secondary btn-sm" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <RefreshCw size={14} className={loadingAnalytics ? 'spin' : ''} />
              Refresh Analytics
            </button>
          </div>

          {loadingAnalytics ? (
            <div style={{ textAlign: 'center', padding: '60px', color: 'var(--text-secondary)' }}>
              <RefreshCw className="spin" size={32} style={{ margin: '0 auto 12px' }} />
              <p>Aggregating measurement and engagement data...</p>
            </div>
          ) : !analyticsData ? (
            <div className="card" style={{ padding: '48px', textAlign: 'center', color: 'var(--text-secondary)' }}>
              <AlertCircle size={40} style={{ margin: '0 auto 12px', opacity: 0.5 }} />
              <p>No analytics data available for the selected scope.</p>
            </div>
          ) : (
            <div>
              {/* Key Performance Indicators */}
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '16px', marginBottom: '24px' }}>
                <div className="card" style={{ padding: '20px', borderLeft: '4px solid #6366f1' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Impressions</span>
                    <Eye size={18} color="#6366f1" />
                  </div>
                  <div style={{ fontSize: '26px', fontWeight: '800', color: 'var(--text-primary)' }}>
                    {analyticsData.total_impressions?.toLocaleString() || 0}
                  </div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    {analyticsData.unique_viewers || 0} unique viewers
                  </div>
                </div>

                <div className="card" style={{ padding: '20px', borderLeft: '4px solid #10b981' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Total Clicks</span>
                    <MousePointer size={18} color="#10b981" />
                  </div>
                  <div style={{ fontSize: '26px', fontWeight: '800', color: 'var(--text-primary)' }}>
                    {analyticsData.total_clicks?.toLocaleString() || 0}
                  </div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    User interactions & CTAs
                  </div>
                </div>

                <div className="card" style={{ padding: '20px', borderLeft: '4px solid #f59e0b' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Click-Through Rate</span>
                    <TrendingUp size={18} color="#f59e0b" />
                  </div>
                  <div style={{ fontSize: '26px', fontWeight: '800', color: 'var(--text-primary)' }}>
                    {analyticsData.click_through_rate !== undefined ? analyticsData.click_through_rate : analyticsData.overall_ctr || 0}%
                  </div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    Clicks / Impressions ratio
                  </div>
                </div>

                <div className="card" style={{ padding: '20px', borderLeft: '4px solid #8b5cf6' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Video Completions</span>
                    <PlayCircle size={18} color="#8b5cf6" />
                  </div>
                  <div style={{ fontSize: '26px', fontWeight: '800', color: 'var(--text-primary)' }}>
                    {analyticsData.video_metrics?.completion_rate || 0}%
                  </div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    {analyticsData.video_metrics?.completions || 0} / {analyticsData.video_metrics?.total_plays || 0} plays
                  </div>
                </div>

                <div className="card" style={{ padding: '20px', borderLeft: '4px solid #ec4899' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Avg Watch Time</span>
                    <Clock size={18} color="#ec4899" />
                  </div>
                  <div style={{ fontSize: '26px', fontWeight: '800', color: 'var(--text-primary)' }}>
                    {analyticsData.video_metrics?.average_watch_duration || 0}s
                  </div>
                  <div style={{ fontSize: '11px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    Average video duration
                  </div>
                </div>
              </div>

              {/* Specific Campaign Details View */}
              {selectedCampaignForAnalytics !== 'ALL' && analyticsData.creatives_performance && (
                <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '24px', marginBottom: '24px' }}>
                  {/* Creative Asset Performance */}
                  <div className="card" style={{ padding: '20px' }}>
                    <h3 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <ImageIcon size={18} color="var(--primary-color)" />
                      Creative Asset Performance Breakdown
                    </h3>
                    {analyticsData.creatives_performance.length === 0 ? (
                      <p style={{ color: 'var(--text-secondary)', fontSize: '13px' }}>No creative asset telemetry recorded yet.</p>
                    ) : (
                      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
                        <thead>
                          <tr style={{ borderBottom: '1px solid var(--border-color)', textAlign: 'left' }}>
                            <th style={{ padding: '10px' }}>Creative Asset</th>
                            <th style={{ padding: '10px' }}>Type</th>
                            <th style={{ padding: '10px' }}>Impressions</th>
                            <th style={{ padding: '10px' }}>Clicks</th>
                            <th style={{ padding: '10px' }}>CTR</th>
                            <th style={{ padding: '10px' }}>Video Plays</th>
                            <th style={{ padding: '10px' }}>Completion Rate</th>
                          </tr>
                        </thead>
                        <tbody>
                          {analyticsData.creatives_performance.map((c) => (
                            <tr key={c.media_id} style={{ borderBottom: '1px solid var(--border-color)' }}>
                              <td style={{ padding: '12px 10px', fontWeight: '700' }}>{c.title}</td>
                              <td style={{ padding: '12px 10px' }}>
                                <span className="badge badge-secondary">{c.media_type_display || c.media_type}</span>
                              </td>
                              <td style={{ padding: '12px 10px' }}>{c.impressions?.toLocaleString()}</td>
                              <td style={{ padding: '12px 10px' }}>{c.clicks?.toLocaleString()}</td>
                              <td style={{ padding: '12px 10px', fontWeight: '700', color: c.ctr > 0 ? '#10b981' : 'inherit' }}>
                                {c.ctr}%
                              </td>
                              <td style={{ padding: '12px 10px' }}>{c.video_plays !== undefined ? c.video_plays : 'N/A'}</td>
                              <td style={{ padding: '12px 10px' }}>
                                {c.completion_rate !== undefined ? `${c.completion_rate}% (${c.avg_watch_duration}s avg)` : 'N/A'}
                              </td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    )}
                  </div>

                  {/* 14-Day Timeline Breakdown */}
                  {analyticsData.timeline && (
                    <div className="card" style={{ padding: '20px' }}>
                      <h3 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <Activity size={18} color="var(--primary-color)" />
                        14-Day Activity & Impression Timeline
                      </h3>
                      <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
                        <thead>
                          <tr style={{ borderBottom: '1px solid var(--border-color)', textAlign: 'left' }}>
                            <th style={{ padding: '10px' }}>Date</th>
                            <th style={{ padding: '10px' }}>Impressions</th>
                            <th style={{ padding: '10px' }}>Clicks</th>
                            <th style={{ padding: '10px' }}>Daily CTR</th>
                          </tr>
                        </thead>
                        <tbody>
                          {analyticsData.timeline.slice().reverse().map((t) => {
                            const dailyCtr = t.impressions > 0 ? ((t.clicks / t.impressions) * 100).toFixed(2) : '0.00';
                            return (
                              <tr key={t.date} style={{ borderBottom: '1px solid var(--border-color)' }}>
                                <td style={{ padding: '10px', fontWeight: '600' }}>{t.date}</td>
                                <td style={{ padding: '10px' }}>{t.impressions}</td>
                                <td style={{ padding: '10px' }}>{t.clicks}</td>
                                <td style={{ padding: '10px', color: dailyCtr > 0 ? '#10b981' : 'inherit' }}>{dailyCtr}%</td>
                              </tr>
                            );
                          })}
                        </tbody>
                      </table>
                    </div>
                  )}
                </div>
              )}

              {/* Platform Overview Top Campaigns View */}
              {selectedCampaignForAnalytics === 'ALL' && analyticsData.top_campaigns && (
                <div className="card" style={{ padding: '20px' }}>
                  <h3 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                    <Layers size={18} color="var(--primary-color)" />
                    Top Performing Campaigns
                  </h3>
                  <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
                    <thead>
                      <tr style={{ borderBottom: '1px solid var(--border-color)', textAlign: 'left' }}>
                        <th style={{ padding: '10px' }}>Campaign Title</th>
                        <th style={{ padding: '10px' }}>Status</th>
                        <th style={{ padding: '10px' }}>Impressions</th>
                        <th style={{ padding: '10px' }}>Clicks</th>
                        <th style={{ padding: '10px' }}>CTR</th>
                        <th style={{ padding: '10px', textAlign: 'right' }}>Actions</th>
                      </tr>
                    </thead>
                    <tbody>
                      {analyticsData.top_campaigns.map((c) => (
                        <tr key={c.id} style={{ borderBottom: '1px solid var(--border-color)' }}>
                          <td style={{ padding: '12px 10px', fontWeight: '700' }}>{c.title}</td>
                          <td style={{ padding: '12px 10px' }}>{renderStatusBadge(c.status)}</td>
                          <td style={{ padding: '12px 10px' }}>{c.impressions?.toLocaleString()}</td>
                          <td style={{ padding: '12px 10px' }}>{c.clicks?.toLocaleString()}</td>
                          <td style={{ padding: '12px 10px', fontWeight: '700', color: c.ctr > 0 ? '#10b981' : 'inherit' }}>
                            {c.ctr}%
                          </td>
                          <td style={{ padding: '12px 10px', textAlign: 'right' }}>
                            <button
                              onClick={() => setSelectedCampaignForAnalytics(c.id)}
                              className="btn btn-secondary btn-sm"
                            >
                              View Campaign Details
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          )}
        </div>
      )}

      {/* BILLING & SPEND TAB (Phase 5.5 Step 5) */}
      {activeTab === 'billing' && (
        <div>
          {/* Header Controls */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
              <span style={{ fontSize: '13px', fontWeight: '700', color: 'var(--text-secondary)' }}>Filter by Campaign:</span>
              <select
                value={selectedCampaignForSpending}
                onChange={(e) => {
                  setSelectedCampaignForSpending(e.target.value);
                  if (e.target.value !== 'ALL') {
                    adminApi.getCampaignSpending(e.target.value).then(setCampaignSpendingData).catch(console.error);
                  }
                }}
                style={{ padding: '8px 12px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-card)', color: 'var(--text-primary)', fontSize: '13px', fontWeight: '600' }}
              >
                <option value="ALL">All Campaigns (Platform Ledger)</option>
                {campaigns.map((c) => (
                  <option key={c.id} value={c.id}>
                    {c.title} ({c.campaign_type_display})
                  </option>
                ))}
              </select>
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button onClick={loadBillingData} className="btn btn-secondary" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <RefreshCw size={14} className={loadingBilling ? 'spin' : ''} />
                Refresh Billing
              </button>
              <button
                onClick={() => {
                  const campId = selectedCampaignForSpending !== 'ALL' ? selectedCampaignForSpending : (campaigns[0]?.id || '');
                  setBudgetConfigForm({
                    campaignId: campId,
                    daily_budget: campaignSpendingData?.daily_budget?.toString() || '20.00',
                    total_budget: campaignSpendingData?.total_budget?.toString() || '100.00',
                    cpm_rate: campaignSpendingData?.cpm_rate?.toString() || '2.00',
                    cpc_rate: campaignSpendingData?.cpc_rate?.toString() || '0.10',
                    cpv_rate: campaignSpendingData?.cpv_rate?.toString() || '0.05',
                    status: campaignSpendingData?.status || 'ACTIVE',
                  });
                  setIsConfigureBudgetModalOpen(true);
                }}
                className="btn btn-secondary"
                style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
              >
                <DollarSign size={14} />
                Configure Budget & Rates
              </button>
              <button onClick={() => setIsFundWalletModalOpen(true)} className="btn btn-primary" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <Wallet size={14} />
                Deposit Funds
              </button>
            </div>
          </div>

          {loadingBilling && !walletData ? (
            <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-secondary)' }}>
              <RefreshCw size={28} className="spin" style={{ margin: '0 auto 12px' }} />
              <p>Loading advertiser financial balances & billing ledger...</p>
            </div>
          ) : (
            <div>
              {/* Financial KPI Cards */}
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '24px' }}>
                <div className="card" style={{ padding: '20px', background: 'linear-gradient(135deg, rgba(16, 185, 129, 0.12), rgba(6, 78, 59, 0.2))', border: '1px solid rgba(16, 185, 129, 0.3)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontSize: '12px', fontWeight: '700', color: '#10b981', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Wallet Balance</span>
                    <Wallet size={20} color="#10b981" />
                  </div>
                  <div style={{ fontSize: '26px', fontWeight: '900', color: 'var(--text-primary)', marginBottom: '4px' }}>
                    ${walletData ? Number(walletData.balance).toFixed(2) : '0.00'}
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                    Currency: {walletData?.currency || 'USD'} • Active & Funded
                  </div>
                </div>

                <div className="card" style={{ padding: '20px', background: 'linear-gradient(135deg, rgba(99, 102, 241, 0.12), rgba(49, 46, 129, 0.2))', border: '1px solid rgba(99, 102, 241, 0.3)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontSize: '12px', fontWeight: '700', color: '#6366f1', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Lifetime Spend</span>
                    <CreditCard size={20} color="#6366f1" />
                  </div>
                  <div style={{ fontSize: '26px', fontWeight: '900', color: 'var(--text-primary)', marginBottom: '4px' }}>
                    ${walletData ? Number(walletData.total_spent).toFixed(2) : '0.00'}
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                    Total monetised ad events billed
                  </div>
                </div>

                <div className="card" style={{ padding: '20px', background: 'linear-gradient(135deg, rgba(245, 158, 11, 0.12), rgba(120, 53, 15, 0.2))', border: '1px solid rgba(245, 158, 11, 0.3)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontSize: '12px', fontWeight: '700', color: '#f59e0b', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Remaining Budget</span>
                    <TrendingUp size={20} color="#f59e0b" />
                  </div>
                  <div style={{ fontSize: '26px', fontWeight: '900', color: 'var(--text-primary)', marginBottom: '4px' }}>
                    ${campaignSpendingData ? Number(campaignSpendingData.remaining_budget).toFixed(2) : '0.00'}
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                    Total Allocated: ${campaignSpendingData ? Number(campaignSpendingData.total_budget).toFixed(2) : '0.00'}
                  </div>
                </div>

                <div className="card" style={{ padding: '20px', background: 'linear-gradient(135deg, rgba(14, 165, 233, 0.12), rgba(12, 74, 110, 0.2))', border: '1px solid rgba(14, 165, 233, 0.3)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                    <span style={{ fontSize: '12px', fontWeight: '700', color: '#0ea5e9', textTransform: 'uppercase', letterSpacing: '0.5px' }}>Active Pricing Rates</span>
                    <Activity size={20} color="#0ea5e9" />
                  </div>
                  <div style={{ fontSize: '16px', fontWeight: '800', color: 'var(--text-primary)', marginTop: '6px' }}>
                    CPM: ${campaignSpendingData ? Number(campaignSpendingData.cpm_rate).toFixed(2) : '2.00'} • CPC: ${campaignSpendingData ? Number(campaignSpendingData.cpc_rate).toFixed(2) : '0.10'}
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                    CPV: ${campaignSpendingData ? Number(campaignSpendingData.cpv_rate).toFixed(2) : '0.05'} (&ge; 95% watch)
                  </div>
                </div>
              </div>

              {/* Campaign Budget Spending Tracker */}
              {campaignSpendingData && (
                <div className="card" style={{ padding: '24px', marginBottom: '24px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px', flexWrap: 'wrap', gap: '10px' }}>
                    <div>
                      <h3 style={{ fontSize: '16px', fontWeight: '800', display: 'flex', alignItems: 'center', gap: '8px', margin: 0 }}>
                        <DollarSign size={18} color="var(--primary-color)" />
                        {campaignSpendingData.campaign_title || 'Campaign'} Spending Controls & Budget Protection
                      </h3>
                      <p style={{ fontSize: '12px', color: 'var(--text-secondary)', margin: '4px 0 0' }}>
                        Automated spending safeguards prevent overspending and stop ad delivery when budget limits are reached.
                      </p>
                    </div>
                    <div>
                      {getStatusBadge(campaignSpendingData.status)}
                    </div>
                  </div>

                  {/* Progress bar */}
                  <div style={{ marginBottom: '12px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '13px', fontWeight: '700', marginBottom: '6px' }}>
                      <span>Spent: ${Number(campaignSpendingData.spent_amount).toFixed(2)} of ${Number(campaignSpendingData.total_budget).toFixed(2)}</span>
                      <span style={{ color: campaignSpendingData.percentage_used >= 90 ? '#ef4444' : '#10b981' }}>
                        {campaignSpendingData.percentage_used}% Used
                      </span>
                    </div>
                    <div style={{ width: '100%', height: '10px', background: 'var(--bg-primary)', borderRadius: '6px', overflow: 'hidden' }}>
                      <div
                        style={{
                          width: `${Math.min(100, campaignSpendingData.percentage_used)}%`,
                          height: '100%',
                          background: campaignSpendingData.percentage_used >= 90 ? '#ef4444' : (campaignSpendingData.percentage_used >= 70 ? '#f59e0b' : 'var(--primary-color)'),
                          transition: 'width 0.3s ease',
                        }}
                      />
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '12px', marginTop: '16px', fontSize: '13px', background: 'var(--bg-primary)', padding: '14px', borderRadius: '8px' }}>
                    <div><strong>Daily Spending Cap:</strong> ${Number(campaignSpendingData.daily_budget).toFixed(2)}</div>
                    <div><strong>Today's Daily Spend:</strong> ${Number(campaignSpendingData.daily_spent_amount).toFixed(2)}</div>
                    <div><strong>Remaining Total:</strong> ${Number(campaignSpendingData.remaining_budget).toFixed(2)}</div>
                    <div><strong>Budget Protection:</strong> <span style={{ color: '#10b981', fontWeight: '700' }}>Active & Enforced</span></div>
                  </div>
                </div>
              )}

              {/* Charge Ledger Table */}
              <div className="card" style={{ padding: '24px' }}>
                <h3 style={{ fontSize: '16px', fontWeight: '800', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <Receipt size={18} color="var(--primary-color)" />
                  Advertisement Billing Charges Ledger
                </h3>

                {billingHistory.length === 0 ? (
                  <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                    <CreditCard size={36} style={{ margin: '0 auto 12px', opacity: 0.5 }} />
                    <p style={{ fontWeight: '600' }}>No billable advertisement charges recorded yet.</p>
                    <p style={{ fontSize: '12px' }}>Charges are generated automatically when user impressions, clicks, or video completions are verified.</p>
                  </div>
                ) : (
                  <div style={{ overflowX: 'auto' }}>
                    <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
                      <thead>
                        <tr style={{ borderBottom: '1px solid var(--border-color)', textAlign: 'left', color: 'var(--text-secondary)' }}>
                          <th style={{ padding: '10px' }}>Date / Time</th>
                          <th style={{ padding: '10px' }}>Campaign</th>
                          <th style={{ padding: '10px' }}>Billable Event</th>
                          <th style={{ padding: '10px' }}>Amount Billed</th>
                          <th style={{ padding: '10px' }}>Reference ID</th>
                          <th style={{ padding: '10px' }}>Fraud Score</th>
                          <th style={{ padding: '10px', textAlign: 'right' }}>Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        {billingHistory.map((charge) => {
                          const isHighRisk = charge.fraud_score >= 70;
                          const isMedRisk = charge.fraud_score >= 40 && charge.fraud_score < 70;
                          return (
                            <tr key={charge.id} style={{ borderBottom: '1px solid var(--border-color)' }}>
                              <td style={{ padding: '12px 10px', color: 'var(--text-secondary)' }}>
                                {new Date(charge.created_at).toLocaleString()}
                              </td>
                              <td style={{ padding: '12px 10px', fontWeight: '700' }}>
                                {charge.campaign_title || charge.campaign}
                              </td>
                              <td style={{ padding: '12px 10px' }}>
                                <span className={`badge ${charge.event_type === 'CLICK' ? 'badge-primary' : (charge.event_type === 'VIDEO_COMPLETION' ? 'badge-success' : 'badge-secondary')}`}>
                                  {charge.event_type}
                                </span>
                              </td>
                              <td style={{ padding: '12px 10px', fontWeight: '800', color: 'var(--text-primary)' }}>
                                ${Number(charge.amount).toFixed(4)}
                              </td>
                              <td style={{ padding: '12px 10px', fontSize: '12px', fontFamily: 'monospace', color: 'var(--text-secondary)' }}>
                                {charge.reference_id?.slice(0, 16)}...
                              </td>
                              <td style={{ padding: '12px 10px' }}>
                                <span style={{
                                  padding: '2px 8px',
                                  borderRadius: '4px',
                                  fontSize: '11px',
                                  fontWeight: '700',
                                  background: isHighRisk ? 'rgba(239, 68, 68, 0.15)' : (isMedRisk ? 'rgba(245, 158, 11, 0.15)' : 'rgba(16, 185, 129, 0.15)'),
                                  color: isHighRisk ? '#ef4444' : (isMedRisk ? '#f59e0b' : '#10b981'),
                                }}>
                                  {charge.fraud_score} / 100 {isHighRisk ? '(High)' : (isMedRisk ? '(Med)' : '(Low)')}
                                </span>
                              </td>
                              <td style={{ padding: '12px 10px', textAlign: 'right' }}>
                                <span className="badge badge-success">Deducted</span>
                              </td>
                            </tr>
                          );
                        })}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </div>
          )}
        </div>
      )}

      {/* FINANCIAL REPORTS & ROI TAB (Phase 5.5 Step 5) */}
      {activeTab === 'reports' && (
        <div>
          {/* Header Bar */}
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h2 style={{ fontSize: '18px', fontWeight: '800', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
                <TrendingUp size={20} color="var(--primary-color)" />
                Advertiser Financial Performance & ROI Attribution Report
              </h2>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)', margin: '4px 0 0' }}>
                Comprehensive return on investment, delivery attribution, and campaign cost effectiveness matrix.
              </p>
            </div>

            <div style={{ display: 'flex', gap: '10px' }}>
              <button
                onClick={() => window.print()}
                className="btn btn-secondary"
                style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
              >
                <Printer size={14} />
                Print Summary
              </button>
              <button
                onClick={handleExportCsv}
                disabled={exportingCsv}
                className="btn btn-primary"
                style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
              >
                <Download size={14} />
                {exportingCsv ? 'Exporting...' : 'Export CSV Report'}
              </button>
            </div>
          </div>

          {loadingReports ? (
            <div style={{ textAlign: 'center', padding: '60px 0', color: 'var(--text-secondary)' }}>
              <RefreshCw size={28} className="spin" style={{ margin: '0 auto 12px' }} />
              <p>Generating financial attribution report...</p>
            </div>
          ) : reportsData && (
            <div>
              {/* Summary Stats Cards */}
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '16px', marginBottom: '24px' }}>
                <div className="card" style={{ padding: '16px' }}>
                  <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Filtered Spend</div>
                  <div style={{ fontSize: '24px', fontWeight: '800', marginTop: '4px' }}>${Number(reportsData.filtered_spent).toFixed(2)}</div>
                </div>
                <div className="card" style={{ padding: '16px' }}>
                  <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Total Charges Ledger</div>
                  <div style={{ fontSize: '24px', fontWeight: '800', marginTop: '4px' }}>{reportsData.total_charges_count} events</div>
                </div>
                <div className="card" style={{ padding: '16px' }}>
                  <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Campaigns Monitored</div>
                  <div style={{ fontSize: '24px', fontWeight: '800', marginTop: '4px' }}>{reportsData.campaigns_count} campaigns</div>
                </div>
                <div className="card" style={{ padding: '16px' }}>
                  <div style={{ fontSize: '12px', fontWeight: '700', color: 'var(--text-secondary)', textTransform: 'uppercase' }}>Wallet Balance Available</div>
                  <div style={{ fontSize: '24px', fontWeight: '800', marginTop: '4px', color: '#10b981' }}>${Number(reportsData.wallet_balance).toFixed(2)}</div>
                </div>
              </div>

              {/* Performance Table */}
              <div className="card" style={{ padding: '24px' }}>
                <h3 style={{ fontSize: '15px', fontWeight: '800', marginBottom: '16px' }}>Campaign Financial & Conversion Matrix</h3>
                <div style={{ overflowX: 'auto' }}>
                  <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
                    <thead>
                      <tr style={{ borderBottom: '1px solid var(--border-color)', textAlign: 'left', color: 'var(--text-secondary)' }}>
                        <th style={{ padding: '10px' }}>Campaign Name</th>
                        <th style={{ padding: '10px' }}>Status</th>
                        <th style={{ padding: '10px' }}>Impressions</th>
                        <th style={{ padding: '10px' }}>Clicks</th>
                        <th style={{ padding: '10px' }}>CTR (%)</th>
                        <th style={{ padding: '10px' }}>Video Comp.</th>
                        <th style={{ padding: '10px' }}>Comp. Rate</th>
                        <th style={{ padding: '10px' }}>Amount Spent</th>
                        <th style={{ padding: '10px' }}>Budget</th>
                        <th style={{ padding: '10px' }}>Remaining</th>
                        <th style={{ padding: '10px', textAlign: 'right' }}>Score</th>
                      </tr>
                    </thead>
                    <tbody>
                      {reportsData.campaigns.map((c) => (
                        <tr key={c.campaign_id} style={{ borderBottom: '1px solid var(--border-color)' }}>
                          <td style={{ padding: '12px 10px', fontWeight: '700' }}>{c.campaign_name}</td>
                          <td style={{ padding: '12px 10px' }}>{getStatusBadge(c.status)}</td>
                          <td style={{ padding: '12px 10px' }}>{c.impressions?.toLocaleString()}</td>
                          <td style={{ padding: '12px 10px' }}>{c.clicks?.toLocaleString()}</td>
                          <td style={{ padding: '12px 10px', fontWeight: '700', color: c.ctr > 0 ? '#10b981' : 'inherit' }}>{c.ctr}%</td>
                          <td style={{ padding: '12px 10px' }}>{c.video_completions?.toLocaleString()}</td>
                          <td style={{ padding: '12px 10px' }}>{c.video_completion_rate}%</td>
                          <td style={{ padding: '12px 10px', fontWeight: '800' }}>${Number(c.amount_spent).toFixed(2)}</td>
                          <td style={{ padding: '12px 10px' }}>${Number(c.total_budget).toFixed(2)}</td>
                          <td style={{ padding: '12px 10px', color: '#10b981', fontWeight: '700' }}>${Number(c.remaining_budget).toFixed(2)}</td>
                          <td style={{ padding: '12px 10px', textAlign: 'right' }}>
                            <span style={{
                              padding: '3px 9px',
                              borderRadius: '4px',
                              fontWeight: '900',
                              fontSize: '12px',
                              background: c.performance_score === 'A' ? '#10b981' : (c.performance_score === 'B' ? '#6366f1' : '#6b7280'),
                              color: '#ffffff',
                            }}>
                              Grade {c.performance_score}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}
        </div>
      )}

      {/* INVOICES & RECEIPTS TAB (Phase 5.5 Step 5) */}
      {activeTab === 'invoices' && (
        <div>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', flexWrap: 'wrap', gap: '12px' }}>
            <div>
              <h2 style={{ fontSize: '18px', fontWeight: '800', margin: 0, display: 'flex', alignItems: 'center', gap: '8px' }}>
                <Receipt size={20} color="var(--primary-color)" />
                Advertiser Tax Invoices & Billing Statements
              </h2>
              <p style={{ fontSize: '13px', color: 'var(--text-secondary)', margin: '4px 0 0' }}>
                Auditable financial records of all deposited funds, CPM impressions, CPC clicks, and CPV video completions.
              </p>
            </div>

            <button onClick={() => window.print()} className="btn btn-secondary" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
              <Printer size={14} />
              Print Invoices
            </button>
          </div>

          <div className="card" style={{ padding: '30px', marginBottom: '24px', background: 'var(--bg-card)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', borderBottom: '2px solid var(--border-color)', paddingBottom: '20px', marginBottom: '20px' }}>
              <div>
                <h2 style={{ fontSize: '22px', fontWeight: '900', color: 'var(--primary-color)', margin: 0 }}>VEWRA ADVERTISING PLATFORM</h2>
                <div style={{ fontSize: '13px', color: 'var(--text-secondary)', marginTop: '4px' }}>
                  Monetisation & Financial Settlement Engine
                </div>
              </div>
              <div style={{ textAlign: 'right', fontSize: '13px' }}>
                <div><strong>Statement Date:</strong> {new Date().toLocaleDateString()}</div>
                <div><strong>Account:</strong> {walletData?.advertiser_email || 'Advertiser Account'}</div>
                <div><strong>Status:</strong> <span style={{ color: '#10b981', fontWeight: '700' }}>Settled</span></div>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '16px', marginBottom: '24px' }}>
              <div style={{ background: 'var(--bg-primary)', padding: '16px', borderRadius: '8px' }}>
                <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Total Deposited</div>
                <div style={{ fontSize: '20px', fontWeight: '800' }}>${Number((walletData?.balance || 0) + (walletData?.total_spent || 0)).toFixed(2)}</div>
              </div>
              <div style={{ background: 'var(--bg-primary)', padding: '16px', borderRadius: '8px' }}>
                <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Total Monetised Spend</div>
                <div style={{ fontSize: '20px', fontWeight: '800' }}>${Number(walletData?.total_spent || 0).toFixed(2)}</div>
              </div>
              <div style={{ background: 'var(--bg-primary)', padding: '16px', borderRadius: '8px' }}>
                <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Available Balance</div>
                <div style={{ fontSize: '20px', fontWeight: '800', color: '#10b981' }}>${Number(walletData?.balance || 0).toFixed(2)}</div>
              </div>
            </div>

            <h4 style={{ fontSize: '14px', fontWeight: '700', marginBottom: '12px' }}>Summary of Billable Advertising Activity</h4>
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '13px' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid var(--border-color)', textAlign: 'left', color: 'var(--text-secondary)' }}>
                  <th style={{ padding: '8px 0' }}>Item Description</th>
                  <th style={{ padding: '8px 0' }}>Billing Model</th>
                  <th style={{ padding: '8px 0', textAlign: 'right' }}>Total Units</th>
                  <th style={{ padding: '8px 0', textAlign: 'right' }}>Unit Rate</th>
                  <th style={{ padding: '8px 0', textAlign: 'right' }}>Subtotal</th>
                </tr>
              </thead>
              <tbody>
                <tr style={{ borderBottom: '1px solid var(--border-color)' }}>
                  <td style={{ padding: '12px 0', fontWeight: '600' }}>Standard Display & Feed Ad Impressions</td>
                  <td style={{ padding: '12px 0' }}>CPM (Cost Per Thousand)</td>
                  <td style={{ padding: '12px 0', textAlign: 'right' }}>{billingHistory.filter(c => c.event_type === 'IMPRESSION').length}</td>
                  <td style={{ padding: '12px 0', textAlign: 'right' }}>$2.00 / 1k</td>
                  <td style={{ padding: '12px 0', textAlign: 'right', fontWeight: '700' }}>
                    ${billingHistory.filter(c => c.event_type === 'IMPRESSION').reduce((sum, c) => sum + Number(c.amount), 0).toFixed(2)}
                  </td>
                </tr>
                <tr style={{ borderBottom: '1px solid var(--border-color)' }}>
                  <td style={{ padding: '12px 0', fontWeight: '600' }}>Verified User Interaction Clicks</td>
                  <td style={{ padding: '12px 0' }}>CPC (Cost Per Click)</td>
                  <td style={{ padding: '12px 0', textAlign: 'right' }}>{billingHistory.filter(c => c.event_type === 'CLICK').length}</td>
                  <td style={{ padding: '12px 0', textAlign: 'right' }}>$0.10 / click</td>
                  <td style={{ padding: '12px 0', textAlign: 'right', fontWeight: '700' }}>
                    ${billingHistory.filter(c => c.event_type === 'CLICK').reduce((sum, c) => sum + Number(c.amount), 0).toFixed(2)}
                  </td>
                </tr>
                <tr style={{ borderBottom: '1px solid var(--border-color)' }}>
                  <td style={{ padding: '12px 0', fontWeight: '600' }}>High-Retention Video Views (&ge;95%)</td>
                  <td style={{ padding: '12px 0' }}>CPV (Cost Per View)</td>
                  <td style={{ padding: '12px 0', textAlign: 'right' }}>{billingHistory.filter(c => c.event_type === 'VIDEO_COMPLETION').length}</td>
                  <td style={{ padding: '12px 0', textAlign: 'right' }}>$0.05 / view</td>
                  <td style={{ padding: '12px 0', textAlign: 'right', fontWeight: '700' }}>
                    ${billingHistory.filter(c => c.event_type === 'VIDEO_COMPLETION').reduce((sum, c) => sum + Number(c.amount), 0).toFixed(2)}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Fund Advertiser Wallet Modal */}
      {isFundWalletModalOpen && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="card" style={{ width: '480px', maxWidth: '90%', padding: '24px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <Wallet size={20} color="var(--primary-color)" />
              Fund Advertiser Wallet
            </h2>
            <p style={{ fontSize: '13px', color: 'var(--text-secondary)', marginBottom: '16px' }}>
              Deposit financial credits to ensure continuous advertisement delivery and prevent campaign pause.
            </p>

            <form onSubmit={handleFundWallet}>
              <div style={{ marginBottom: '16px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Deposit Amount (USD)</label>
                <input
                  type="number"
                  step="1.00"
                  min="1"
                  required
                  value={fundAmount}
                  onChange={(e) => setFundAmount(e.target.value)}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)', fontSize: '16px', fontWeight: '700' }}
                />
              </div>

              {/* Quick amount chips */}
              <div style={{ display: 'flex', gap: '8px', marginBottom: '20px' }}>
                {['25.00', '50.00', '100.00', '250.00', '500.00'].map((amt) => (
                  <button
                    key={amt}
                    type="button"
                    onClick={() => setFundAmount(amt)}
                    className="btn btn-secondary btn-sm"
                    style={{ flex: 1 }}
                  >
                    +${amt}
                  </button>
                ))}
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                <button type="button" onClick={() => setIsFundWalletModalOpen(false)} className="btn btn-secondary">Cancel</button>
                <button type="submit" disabled={submittingFund} className="btn btn-primary">
                  {submittingFund ? 'Processing...' : 'Deposit Funds'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Configure Budget & Rates Modal */}
      {isConfigureBudgetModalOpen && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.6)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="card" style={{ width: '540px', maxWidth: '90%', padding: '24px' }}>
            <h2 style={{ fontSize: '18px', fontWeight: '800', marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
              <DollarSign size={20} color="var(--primary-color)" />
              Configure Campaign Budget & Rates
            </h2>

            <form onSubmit={handleConfigureBudget}>
              <div style={{ marginBottom: '14px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Campaign</label>
                <select
                  value={budgetConfigForm.campaignId}
                  onChange={(e) => setBudgetConfigForm({ ...budgetConfigForm, campaignId: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                >
                  {campaigns.map((c) => (
                    <option key={c.id} value={c.id}>
                      {c.title} ({c.campaign_type_display})
                    </option>
                  ))}
                </select>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', marginBottom: '14px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Total Budget ($)</label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    required
                    value={budgetConfigForm.total_budget}
                    onChange={(e) => setBudgetConfigForm({ ...budgetConfigForm, total_budget: e.target.value })}
                    style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                  />
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Daily Budget Cap ($)</label>
                  <input
                    type="number"
                    step="0.01"
                    min="0"
                    required
                    value={budgetConfigForm.daily_budget}
                    onChange={(e) => setBudgetConfigForm({ ...budgetConfigForm, daily_budget: e.target.value })}
                    style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                  />
                </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '10px', marginBottom: '14px' }}>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>CPM Rate ($/1k)</label>
                  <input
                    type="number"
                    step="0.10"
                    min="0.10"
                    required
                    value={budgetConfigForm.cpm_rate}
                    onChange={(e) => setBudgetConfigForm({ ...budgetConfigForm, cpm_rate: e.target.value })}
                    style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                  />
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>CPC Rate ($/click)</label>
                  <input
                    type="number"
                    step="0.01"
                    min="0.01"
                    required
                    value={budgetConfigForm.cpc_rate}
                    onChange={(e) => setBudgetConfigForm({ ...budgetConfigForm, cpc_rate: e.target.value })}
                    style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                  />
                </div>
                <div>
                  <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>CPV Rate ($/view)</label>
                  <input
                    type="number"
                    step="0.01"
                    min="0.01"
                    required
                    value={budgetConfigForm.cpv_rate}
                    onChange={(e) => setBudgetConfigForm({ ...budgetConfigForm, cpv_rate: e.target.value })}
                    style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                  />
                </div>
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', fontSize: '12px', fontWeight: '700', marginBottom: '6px' }}>Budget Status</label>
                <select
                  value={budgetConfigForm.status}
                  onChange={(e) => setBudgetConfigForm({ ...budgetConfigForm, status: e.target.value })}
                  style={{ width: '100%', padding: '10px', borderRadius: '8px', border: '1px solid var(--border-color)', background: 'var(--bg-primary)', color: 'var(--text-primary)' }}
                >
                  <option value="ACTIVE">Active (Spend permitted)</option>
                  <option value="PAUSED">Paused (Delivery halted)</option>
                </select>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
                <button type="button" onClick={() => setIsConfigureBudgetModalOpen(false)} className="btn btn-secondary">Cancel</button>
                <button type="submit" disabled={submittingBudgetConfig} className="btn btn-primary">
                  {submittingBudgetConfig ? 'Saving...' : 'Save Configuration'}
                </button>
              </div>
            </form>
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
