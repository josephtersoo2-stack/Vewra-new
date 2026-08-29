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
} from 'lucide-react';
import { adminApi } from '../api/adminApi';

export function CampaignsPage() {
  const [campaigns, setCampaigns] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeType, setActiveType] = useState('ALL');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [searchQuery, setSearchQuery] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  // Form State
  const [formData, setFormData] = useState({
    title: '',
    campaign_type: 'TASK',
    description: '',
    budget: '100.00',
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

  useEffect(() => {
    loadCampaigns();
  }, [activeType, statusFilter]);

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
      loadCampaigns();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to create campaign');
    } finally {
      setSubmitting(false);
    }
  };

  const handleApprove = async (id) => {
    if (!window.confirm('Approve and activate this campaign?')) return;
    try {
      await adminApi.approveCampaign(id);
      loadCampaigns();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to approve campaign');
    }
  };

  const handleReject = async (id) => {
    const reason = window.prompt('Enter rejection reason (optional):');
    if (reason === null) return;
    try {
      await adminApi.rejectCampaign(id, reason);
      loadCampaigns();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to reject campaign');
    }
  };

  const handlePause = async (id) => {
    if (!window.confirm('Pause this active campaign?')) return;
    try {
      await adminApi.pauseCampaign(id);
      loadCampaigns();
    } catch (err) {
      alert(err.response?.data?.error || 'Failed to pause campaign');
    }
  };

  // Metrics calculation
  const totalBudget = campaigns.reduce((acc, c) => acc + (parseFloat(c.budget) || 0), 0);
  const activeCount = campaigns.filter((c) => c.status === 'ACTIVE').length;
  const pendingCount = campaigns.filter((c) => c.status === 'PENDING_REVIEW').length;

  const getStatusBadge = (status) => {
    const styles = {
      ACTIVE: { bg: 'rgba(16, 185, 129, 0.15)', text: '#10B981', label: 'Active' },
      PENDING_REVIEW: { bg: 'rgba(245, 158, 11, 0.15)', text: '#F59E0B', label: 'Pending Review' },
      DRAFT: { bg: 'rgba(148, 163, 184, 0.15)', text: '#94A3B8', label: 'Draft' },
      PAUSED: { bg: 'rgba(99, 102, 241, 0.15)', text: '#6366F1', label: 'Paused' },
      REJECTED: { bg: 'rgba(239, 68, 68, 0.15)', text: '#EF4444', label: 'Rejected' },
      COMPLETED: { bg: 'rgba(59, 130, 246, 0.15)', text: '#3B82F6', label: 'Completed' },
    };
    const s = styles[status] || styles.DRAFT;
    return (
      <span
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: '6px',
          padding: '4px 10px',
          borderRadius: '999px',
          fontSize: '12px',
          fontWeight: '700',
          backgroundColor: s.bg,
          color: s.text,
        }}
      >
        <span style={{ width: '6px', height: '6px', borderRadius: '50%', backgroundColor: s.text }} />
        {s.label}
      </span>
    );
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Top Header & Action */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h2 style={{ fontSize: '24px', fontWeight: '800', color: 'var(--text-primary)', margin: 0 }}>
            Campaign Management
          </h2>
          <p style={{ color: 'var(--text-secondary)', fontSize: '14px', marginTop: '4px' }}>
            Unified Campaign Engine: Task Campaigns, Advertisements & Sponsored Content
          </p>
        </div>
        <button
          onClick={() => setIsModalOpen(true)}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '8px',
            padding: '12px 20px',
            backgroundColor: 'var(--primary)',
            color: '#FFFFFF',
            border: 'none',
            borderRadius: 'var(--btn-radius)',
            fontWeight: '700',
            cursor: 'pointer',
            boxShadow: '0 4px 14px rgba(99, 102, 241, 0.35)',
          }}
        >
          <Plus size={18} />
          Create Campaign
        </button>
      </div>

      {/* KPI Stats Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px' }}>
        <div style={{ backgroundColor: 'var(--bg-secondary)', padding: '20px', borderRadius: '16px', border: '1px solid var(--border-subtle)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: 'var(--text-tertiary)' }}>
            <Layers size={18} />
            <span style={{ fontSize: '13px', fontWeight: '600' }}>Total Campaigns</span>
          </div>
          <p style={{ fontSize: '28px', fontWeight: '800', color: 'var(--text-primary)', margin: '10px 0 0 0' }}>
            {campaigns.length}
          </p>
        </div>

        <div style={{ backgroundColor: 'var(--bg-secondary)', padding: '20px', borderRadius: '16px', border: '1px solid var(--border-subtle)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: '#10B981' }}>
            <CheckCircle size={18} />
            <span style={{ fontSize: '13px', fontWeight: '600' }}>Active Campaigns</span>
          </div>
          <p style={{ fontSize: '28px', fontWeight: '800', color: '#10B981', margin: '10px 0 0 0' }}>
            {activeCount}
          </p>
        </div>

        <div style={{ backgroundColor: 'var(--bg-secondary)', padding: '20px', borderRadius: '16px', border: '1px solid var(--border-subtle)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: '#F59E0B' }}>
            <Clock size={18} />
            <span style={{ fontSize: '13px', fontWeight: '600' }}>Pending Approval</span>
          </div>
          <p style={{ fontSize: '28px', fontWeight: '800', color: '#F59E0B', margin: '10px 0 0 0' }}>
            {pendingCount}
          </p>
        </div>

        <div style={{ backgroundColor: 'var(--bg-secondary)', padding: '20px', borderRadius: '16px', border: '1px solid var(--border-subtle)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: 'var(--primary)' }}>
            <DollarSign size={18} />
            <span style={{ fontSize: '13px', fontWeight: '600' }}>Allocated Budget</span>
          </div>
          <p style={{ fontSize: '28px', fontWeight: '800', color: 'var(--text-primary)', margin: '10px 0 0 0' }}>
            ${totalBudget.toLocaleString('en-US', { minimumFractionDigits: 2 })}
          </p>
        </div>
      </div>

      {/* Filter and Search Controls */}
      <div style={{ backgroundColor: 'var(--bg-secondary)', padding: '16px 20px', borderRadius: '16px', border: '1px solid var(--border-subtle)', display: 'flex', flexWrap: 'wrap', gap: '16px', alignItems: 'center', justifyContent: 'space-between' }}>
        {/* Type Tabs */}
        <div style={{ display: 'flex', gap: '8px' }}>
          {[
            { label: 'All Types', value: 'ALL' },
            { label: 'Task Campaigns', value: 'TASK' },
            { label: 'Advertisements', value: 'ADVERTISEMENT' },
            { label: 'Sponsored Content', value: 'SPONSORED_CONTENT' },
          ].map((tab) => (
            <button
              key={tab.value}
              onClick={() => setActiveType(tab.value)}
              style={{
                padding: '8px 14px',
                borderRadius: '8px',
                border: 'none',
                backgroundColor: activeType === tab.value ? 'var(--primary)' : 'transparent',
                color: activeType === tab.value ? '#FFFFFF' : 'var(--text-secondary)',
                fontWeight: activeType === tab.value ? '700' : '500',
                cursor: 'pointer',
                fontSize: '13px',
              }}
            >
              {tab.label}
            </button>
          ))}
        </div>

        {/* Search & Status Filters */}
        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            style={{
              padding: '8px 12px',
              borderRadius: '8px',
              backgroundColor: 'var(--bg-primary)',
              color: 'var(--text-primary)',
              border: '1px solid var(--border-subtle)',
              fontSize: '13px',
            }}
          >
            <option value="ALL">All Statuses</option>
            <option value="ACTIVE">Active</option>
            <option value="PENDING_REVIEW">Pending Review</option>
            <option value="DRAFT">Draft</option>
            <option value="PAUSED">Paused</option>
            <option value="REJECTED">Rejected</option>
          </select>

          <form onSubmit={handleSearchSubmit} style={{ display: 'flex', gap: '8px' }}>
            <div style={{ position: 'relative', display: 'flex', alignItems: 'center' }}>
              <Search size={16} style={{ position: 'absolute', left: '12px', color: 'var(--text-tertiary)' }} />
              <input
                type="text"
                placeholder="Search campaigns..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{
                  padding: '8px 12px 8px 36px',
                  borderRadius: '8px',
                  backgroundColor: 'var(--bg-primary)',
                  color: 'var(--text-primary)',
                  border: '1px solid var(--border-subtle)',
                  fontSize: '13px',
                  width: '200px',
                }}
              />
            </div>
            <button
              type="submit"
              style={{
                padding: '8px 12px',
                borderRadius: '8px',
                backgroundColor: 'var(--bg-primary)',
                border: '1px solid var(--border-subtle)',
                color: 'var(--text-primary)',
                cursor: 'pointer',
              }}
            >
              <RefreshCw size={14} />
            </button>
          </form>
        </div>
      </div>

      {/* Campaigns Data Table */}
      <div style={{ backgroundColor: 'var(--bg-secondary)', borderRadius: '16px', border: '1px solid var(--border-subtle)', overflow: 'hidden' }}>
        {loading ? (
          <div style={{ padding: '48px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            <RefreshCw size={24} className="spin-animation" style={{ marginBottom: '12px' }} />
            <p>Loading campaigns catalogue...</p>
          </div>
        ) : error ? (
          <div style={{ padding: '48px', textAlign: 'center', color: 'var(--accent-rose)' }}>
            <AlertCircle size={24} style={{ marginBottom: '12px' }} />
            <p>{error}</p>
          </div>
        ) : campaigns.length === 0 ? (
          <div style={{ padding: '48px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            <Megaphone size={32} style={{ marginBottom: '12px', opacity: 0.5 }} />
            <p style={{ fontWeight: '600' }}>No campaigns found.</p>
            <p style={{ fontSize: '13px', marginTop: '4px' }}>Create a campaign to get started with advertising.</p>
          </div>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left', fontSize: '14px' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border-subtle)', color: 'var(--text-tertiary)', fontSize: '12px' }}>
                <th style={{ padding: '16px 20px' }}>CAMPAIGN</th>
                <th style={{ padding: '16px 20px' }}>TYPE</th>
                <th style={{ padding: '16px 20px' }}>OWNER</th>
                <th style={{ padding: '16px 20px' }}>STATUS</th>
                <th style={{ padding: '16px 20px' }}>BUDGET</th>
                <th style={{ padding: '16px 20px' }}>ACTIONS</th>
              </tr>
            </thead>
            <tbody>
              {campaigns.map((c) => (
                <tr key={c.id} style={{ borderBottom: '1px solid var(--border-subtle)' }}>
                  <td style={{ padding: '16px 20px' }}>
                    <div style={{ fontWeight: '700', color: 'var(--text-primary)' }}>{c.title}</div>
                    <div style={{ fontSize: '11px', color: 'var(--text-tertiary)', marginTop: '2px' }}>
                      ID: {c.id}
                    </div>
                  </td>
                  <td style={{ padding: '16px 20px' }}>
                    <span
                      style={{
                        padding: '4px 8px',
                        borderRadius: '6px',
                        backgroundColor: 'var(--primary-light)',
                        color: 'var(--primary)',
                        fontSize: '12px',
                        fontWeight: '600',
                      }}
                    >
                      {c.campaign_type_display || c.campaign_type}
                    </span>
                  </td>
                  <td style={{ padding: '16px 20px', color: 'var(--text-secondary)' }}>
                    {c.owner_details?.email || 'System'}
                  </td>
                  <td style={{ padding: '16px 20px' }}>{getStatusBadge(c.status)}</td>
                  <td style={{ padding: '16px 20px', fontWeight: '700', color: 'var(--text-primary)' }}>
                    ${parseFloat(c.budget || 0).toFixed(2)}
                  </td>
                  <td style={{ padding: '16px 20px' }}>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      {c.status === 'PENDING_REVIEW' && (
                        <>
                          <button
                            onClick={() => handleApprove(c.id)}
                            style={{
                              padding: '6px 12px',
                              borderRadius: '6px',
                              backgroundColor: 'rgba(16, 185, 129, 0.2)',
                              color: '#10B981',
                              border: '1px solid rgba(16, 185, 129, 0.4)',
                              cursor: 'pointer',
                              fontWeight: '600',
                              fontSize: '12px',
                            }}
                          >
                            Approve
                          </button>
                          <button
                            onClick={() => handleReject(c.id)}
                            style={{
                              padding: '6px 12px',
                              borderRadius: '6px',
                              backgroundColor: 'rgba(239, 68, 68, 0.2)',
                              color: '#EF4444',
                              border: '1px solid rgba(239, 68, 68, 0.4)',
                              cursor: 'pointer',
                              fontWeight: '600',
                              fontSize: '12px',
                            }}
                          >
                            Reject
                          </button>
                        </>
                      )}
                      {c.status === 'ACTIVE' && (
                        <button
                          onClick={() => handlePause(c.id)}
                          style={{
                            padding: '6px 12px',
                            borderRadius: '6px',
                            backgroundColor: 'rgba(99, 102, 241, 0.2)',
                            color: '#6366F1',
                            border: '1px solid rgba(99, 102, 241, 0.4)',
                            cursor: 'pointer',
                            fontWeight: '600',
                            fontSize: '12px',
                          }}
                        >
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

      {/* Create Campaign Modal */}
      {isModalOpen && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            backgroundColor: 'rgba(0, 0, 0, 0.6)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 1000,
          }}
        >
          <div
            style={{
              backgroundColor: 'var(--bg-secondary)',
              padding: '32px',
              borderRadius: '20px',
              width: '100%',
              maxWidth: '520px',
              border: '1px solid var(--border-subtle)',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
              <h3 style={{ fontSize: '18px', fontWeight: '800', color: 'var(--text-primary)', margin: 0 }}>
                Create New Campaign
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                style={{ background: 'none', border: 'none', color: 'var(--text-tertiary)', cursor: 'pointer' }}
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleCreateCampaign} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: '600', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  Campaign Title
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Summer Promo 2026"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    borderRadius: '8px',
                    backgroundColor: 'var(--bg-primary)',
                    border: '1px solid var(--border-subtle)',
                    color: 'var(--text-primary)',
                    fontSize: '14px',
                    boxSizing: 'border-box',
                  }}
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: '600', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  Campaign Type
                </label>
                <select
                  value={formData.campaign_type}
                  onChange={(e) => setFormData({ ...formData, campaign_type: e.target.value })}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    borderRadius: '8px',
                    backgroundColor: 'var(--bg-primary)',
                    border: '1px solid var(--border-subtle)',
                    color: 'var(--text-primary)',
                    fontSize: '14px',
                    boxSizing: 'border-box',
                  }}
                >
                  <option value="TASK">Task Campaign</option>
                  <option value="ADVERTISEMENT">Advertisement Campaign</option>
                  <option value="SPONSORED_CONTENT">Sponsored Content Campaign</option>
                </select>
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: '600', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  Budget (USD)
                </label>
                <input
                  type="number"
                  step="0.01"
                  min="0"
                  required
                  value={formData.budget}
                  onChange={(e) => setFormData({ ...formData, budget: e.target.value })}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    borderRadius: '8px',
                    backgroundColor: 'var(--bg-primary)',
                    border: '1px solid var(--border-subtle)',
                    color: 'var(--text-primary)',
                    fontSize: '14px',
                    boxSizing: 'border-box',
                  }}
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '13px', fontWeight: '600', color: 'var(--text-secondary)', marginBottom: '6px' }}>
                  Description
                </label>
                <textarea
                  rows="3"
                  placeholder="Overview of the campaign goals..."
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    borderRadius: '8px',
                    backgroundColor: 'var(--bg-primary)',
                    border: '1px solid var(--border-subtle)',
                    color: 'var(--text-primary)',
                    fontSize: '14px',
                    boxSizing: 'border-box',
                  }}
                />
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '12px' }}>
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  style={{
                    padding: '10px 16px',
                    borderRadius: '8px',
                    backgroundColor: 'transparent',
                    border: '1px solid var(--border-subtle)',
                    color: 'var(--text-secondary)',
                    cursor: 'pointer',
                    fontWeight: '600',
                  }}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  style={{
                    padding: '10px 20px',
                    borderRadius: '8px',
                    backgroundColor: 'var(--primary)',
                    border: 'none',
                    color: '#FFFFFF',
                    cursor: 'pointer',
                    fontWeight: '700',
                  }}
                >
                  {submitting ? 'Creating...' : 'Create Draft'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
