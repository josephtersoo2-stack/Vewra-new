import React, { useState, useEffect } from 'react';
import {
  Sparkles,
  Plus,
  X,
  RefreshCw,
  Video,
  Coins,
  Clock,
  CheckCircle2,
  AlertCircle,
  ExternalLink,
  HelpCircle,
  ShieldCheck,
  Calendar,
  Layers,
  Award,
  DollarSign,
  Zap,
  BookOpen,
  Trash2,
} from 'lucide-react';
import { adminApi } from '../api/adminApi';
import { Modal } from '../components/ui/Modal';
import { Badge } from '../components/ui/Badge';

export function TaskModal({ isOpen, onClose, task, onSaved }) {
  const [activeTab, setActiveTab] = useState('basic');

  // Basic Video Info
  const [sourceUrl, setSourceUrl] = useState('');
  const [videoId, setVideoId] = useState('');
  const [title, setTitle] = useState('');
  const [channelName, setChannelName] = useState('');
  const [thumbnailUrl, setThumbnailUrl] = useState('');
  const [taskType, setTaskType] = useState('VIDEO');
  const [status, setStatus] = useState('ACTIVE');
  const [description, setDescription] = useState('');
  const [instructions, setInstructions] = useState('');

  // AI & Keywords
  const [keywords, setKeywords] = useState([]);
  const [searchKeywords, setSearchKeywords] = useState('');
  const [newKeywordInput, setNewKeywordInput] = useState('');

  // Reward Configuration
  const [rewardType, setRewardType] = useState('target');
  const [rewardCoins, setRewardCoins] = useState(10);
  const [rewardCash, setRewardCash] = useState('0.00');
  const [rewardXp, setRewardXp] = useState(25);
  const [requiredWatchSeconds, setRequiredWatchSeconds] = useState(60);
  const [intervalSeconds, setIntervalSeconds] = useState(60);
  const [targetSeconds, setTargetSeconds] = useState(60);

  // Quiz Verification
  const [quizRequired, setQuizRequired] = useState(false);
  const [quizPassPercentage, setQuizPassPercentage] = useState(70);
  const [quizQuestions, setQuizQuestions] = useState([]);

  // Eligibility & Limits
  const [dailyUserLimit, setDailyUserLimit] = useState(1);
  const [totalCompletionLimit, setTotalCompletionLimit] = useState('');
  const [totalCompletions, setTotalCompletions] = useState(0);
  const [minimumLevel, setMinimumLevel] = useState(1);
  const [minimumTrustScore, setMinimumTrustScore] = useState(50);
  const [verificationRequired, setVerificationRequired] = useState(false);

  // Scheduling & Metadata
  const [startsAt, setStartsAt] = useState('');
  const [expiresAt, setExpiresAt] = useState('');
  const [createdByEmail, setCreatedByEmail] = useState('');
  const [createdAt, setCreatedAt] = useState('');
  const [updatedAt, setUpdatedAt] = useState('');

  // Loaders & Errors
  const [loadingMeta, setLoadingMeta] = useState(false);
  const [regeneratingKeywords, setRegeneratingKeywords] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const formatDateTimeLocal = (dateStr) => {
    if (!dateStr) return '';
    try {
      const d = new Date(dateStr);
      return new Date(d.getTime() - d.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
    } catch {
      return '';
    }
  };

  useEffect(() => {
    if (task) {
      setSourceUrl(task.source_url || task.youtube_url || '');
      setVideoId(task.video_id || '');
      setTitle(task.title || '');
      setChannelName(task.channel_name || '');
      setThumbnailUrl(task.thumbnail_url || '');
      setTaskType(task.task_type || 'VIDEO');
      setStatus(task.status || (task.is_active === false ? 'PAUSED' : 'ACTIVE'));
      setDescription(task.description || '');
      setInstructions(Array.isArray(task.instructions) ? task.instructions.join('\n') : (task.instructions || ''));

      setKeywords(Array.isArray(task.keywords) ? task.keywords : []);
      setSearchKeywords(task.search_keywords || '');

      setRewardType(task.reward_type || 'target');
      setRewardCoins(task.reward_coins ?? 10);
      setRewardCash(task.reward_cash || '0.00');
      setRewardXp(task.reward_xp ?? 25);
      setRequiredWatchSeconds(task.required_watch_seconds ?? 60);

      const cfg = task.reward_config || {};
      setIntervalSeconds(cfg.seconds || 60);
      setTargetSeconds(cfg.target_seconds || task.required_watch_seconds || 60);

      setQuizRequired(task.quiz_required ?? false);
      setQuizPassPercentage(task.quiz_pass_percentage ?? 70);
      setQuizQuestions(Array.isArray(task.quiz_questions) ? task.quiz_questions : []);

      setDailyUserLimit(task.daily_user_limit ?? 1);
      setTotalCompletionLimit(task.total_completion_limit ?? '');
      setTotalCompletions(task.total_completions ?? 0);
      setMinimumLevel(task.minimum_level ?? 1);
      setMinimumTrustScore(task.minimum_trust_score ?? 50);
      setVerificationRequired(task.verification_required ?? false);

      setStartsAt(formatDateTimeLocal(task.starts_at));
      setExpiresAt(formatDateTimeLocal(task.expires_at));
      setCreatedByEmail(task.created_by_email || '');
      setCreatedAt(task.created_at || '');
      setUpdatedAt(task.updated_at || '');
    } else {
      setSourceUrl('');
      setVideoId('');
      setTitle('');
      setChannelName('');
      setThumbnailUrl('');
      setTaskType('VIDEO');
      setStatus('ACTIVE');
      setDescription('');
      setInstructions('');

      setKeywords([]);
      setSearchKeywords('');

      setRewardType('target');
      setRewardCoins(10);
      setRewardCash('0.00');
      setRewardXp(25);
      setRequiredWatchSeconds(60);
      setIntervalSeconds(60);
      setTargetSeconds(60);

      setQuizRequired(false);
      setQuizPassPercentage(70);
      setQuizQuestions([]);

      setDailyUserLimit(1);
      setTotalCompletionLimit('');
      setTotalCompletions(0);
      setMinimumLevel(1);
      setMinimumTrustScore(50);
      setVerificationRequired(false);

      setStartsAt('');
      setExpiresAt('');
      setCreatedByEmail('');
      setCreatedAt('');
      setUpdatedAt('');
    }
    setActiveTab('basic');
    setError('');
  }, [task, isOpen]);

  const handleFetchMetadata = async (customUrl) => {
    const target = (typeof customUrl === 'string' ? customUrl : sourceUrl).trim();
    if (!target) return;
    setLoadingMeta(true);
    setError('');
    try {
      const res = await adminApi.fetchYouTubeMeta(target);
      const meta = res.data || res;
      if (meta.video_id) setVideoId(meta.video_id);
      if (meta.title) setTitle(meta.title);
      if (meta.channel) setChannelName(meta.channel);
      if (meta.thumbnail_url) setThumbnailUrl(meta.thumbnail_url);
      if (meta.keywords && Array.isArray(meta.keywords) && meta.keywords.length > 0) {
        setKeywords(meta.keywords);
        setSearchKeywords(meta.keywords[0]);
      }
    } catch (err) {
      setError(err.response?.data?.message || err.message || 'Failed to auto-fetch YouTube metadata.');
    } finally {
      setLoadingMeta(false);
    }
  };

  // Automatically fetch metadata when a valid YouTube URL or ID is pasted/entered
  const handleUrlChange = (val) => {
    setSourceUrl(val);
    const clean = val.trim();
    if (
      clean.includes('youtube.com/watch') ||
      clean.includes('youtu.be/') ||
      clean.includes('youtube.com/shorts') ||
      (clean.length === 11 && !clean.includes(' '))
    ) {
      // Auto-trigger metadata fetch immediately
      handleFetchMetadata(clean);
    }
  };

  const handleRegenerateKeywords = async () => {
    if (!sourceUrl && !videoId) return;
    setRegeneratingKeywords(true);
    setError('');
    try {
      const url = sourceUrl || `https://www.youtube.com/watch?v=${videoId}`;
      const res = await adminApi.fetchYouTubeMeta(url);
      const meta = res.data || res;
      if (meta.keywords && meta.keywords.length > 0) {
        setKeywords(meta.keywords);
        if (!searchKeywords) setSearchKeywords(meta.keywords[0]);
      }
    } catch (err) {
      setError('Failed to regenerate keywords: ' + (err.response?.data?.message || err.message));
    } finally {
      setRegeneratingKeywords(false);
    }
  };

  const handleAddKeyword = (e) => {
    e.preventDefault();
    const clean = newKeywordInput.trim();
    if (clean && !keywords.includes(clean)) {
      setKeywords([...keywords, clean]);
      setNewKeywordInput('');
    }
  };

  const handleRemoveKeyword = (indexToRemove) => {
    setKeywords(keywords.filter((_, idx) => idx !== indexToRemove));
  };

  const handleAddQuizQuestion = () => {
    setQuizQuestions([
      ...quizQuestions,
      {
        question_text: '',
        question_type: 'MULTIPLE_CHOICE',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correct_answer: 'Option A',
        explanation: '',
        difficulty: 'MEDIUM',
        active: true,
      },
    ]);
  };

  const handleUpdateQuizQuestion = (index, field, value) => {
    const updated = [...quizQuestions];
    updated[index] = { ...updated[index], [field]: value };
    setQuizQuestions(updated);
  };

  const handleUpdateQuizOption = (qIndex, optIndex, value) => {
    const updated = [...quizQuestions];
    const opts = [...(updated[qIndex].options || [])];
    opts[optIndex] = value;
    updated[qIndex].options = opts;
    setQuizQuestions(updated);
  };

  const handleRemoveQuizQuestion = (index) => {
    setQuizQuestions(quizQuestions.filter((_, idx) => idx !== index));
  };

  const setNow = (setter) => {
    const now = new Date();
    setter(new Date(now.getTime() - now.getTimezoneOffset() * 60000).toISOString().slice(0, 16));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    setError('');

    let reward_config = {};
    if (rewardType === 'per_time') {
      reward_config = { coins: Number(rewardCoins), seconds: Number(intervalSeconds) };
    } else if (rewardType === 'watch_all') {
      reward_config = { coins: Number(rewardCoins), duration: Number(requiredWatchSeconds) };
    } else if (rewardType === 'target') {
      reward_config = { coins: Number(rewardCoins), target_seconds: Number(targetSeconds) };
    }

    const payload = {
      source_url: sourceUrl,
      source_platform: 'YouTube',
      video_id: videoId,
      title,
      channel_name: channelName,
      thumbnail_url: thumbnailUrl,
      task_type: taskType,
      status,
      description,
      instructions: instructions ? instructions.split('\n').filter(Boolean) : [],

      reward_type: rewardType,
      reward_config,
      reward_coins: Number(rewardCoins),
      reward_cash: rewardCash,
      reward_xp: Number(rewardXp),
      required_watch_seconds: Number(rewardType === 'target' ? targetSeconds : requiredWatchSeconds),

      quiz_required: quizRequired,
      quiz_pass_percentage: Number(quizPassPercentage),
      quiz_questions: quizQuestions,

      keywords,
      search_keywords: searchKeywords || (keywords.length > 0 ? keywords[0] : ''),

      daily_user_limit: Number(dailyUserLimit) || 1,
      total_completion_limit: totalCompletionLimit ? Number(totalCompletionLimit) : null,
      minimum_level: Number(minimumLevel) || 1,
      minimum_trust_score: Number(minimumTrustScore) || 50,
      verification_required: Boolean(verificationRequired),

      starts_at: startsAt ? new Date(startsAt).toISOString() : null,
      expires_at: expiresAt ? new Date(expiresAt).toISOString() : null,
    };

    try {
      if (task) {
        await adminApi.updateVideoTask(task.id, payload);
      } else {
        await adminApi.createVideoTask(payload);
      }
      onSaved();
      onClose();
    } catch (err) {
      const respData = err.response?.data;
      setError(
        typeof respData === 'string'
          ? respData
          : respData?.detail || respData?.message || JSON.stringify(respData) || err.message
      );
    } finally {
      setSaving(false);
    }
  };

  const tabStyle = (id) => ({
    padding: '8px 16px',
    fontSize: '13px',
    fontWeight: '600',
    borderRadius: 'var(--btn-radius)',
    border: 'none',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    backgroundColor: activeTab === id ? 'var(--primary)' : 'transparent',
    color: activeTab === id ? '#fff' : 'var(--text-secondary)',
    transition: 'all 0.15s ease',
  });

  const inputStyle = {
    width: '100%',
    padding: '10px 14px',
    borderRadius: 'var(--input-radius)',
    backgroundColor: 'var(--bg-tertiary)',
    border: '1px solid var(--border-card)',
    color: 'var(--text-primary)',
    fontSize: '13px',
    outline: 'none',
  };

  const labelStyle = {
    fontSize: '12px',
    fontWeight: '600',
    color: 'var(--text-secondary)',
    display: 'block',
    marginBottom: '6px',
    textTransform: 'uppercase',
    letterSpacing: '0.5px',
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={task ? `Edit Video Task: ${title || 'Task'}` : 'Add YouTube Video Task'}
      maxWidth="850px"
    >
      {/* Tab Navigation */}
      <div
        style={{
          display: 'flex',
          gap: '8px',
          borderBottom: '1px solid var(--border-card)',
          paddingBottom: '12px',
          marginBottom: '20px',
          overflowX: 'auto',
        }}
      >
        <button type="button" onClick={() => setActiveTab('basic')} style={tabStyle('basic')}>
          <Video size={15} /> Video & Details
        </button>
        <button type="button" onClick={() => setActiveTab('ai')} style={tabStyle('ai')}>
          <Sparkles size={15} /> AI Keywords ({keywords.length})
        </button>
        <button type="button" onClick={() => setActiveTab('reward')} style={tabStyle('reward')}>
          <Coins size={15} /> Rewards & Watch Time
        </button>
        <button type="button" onClick={() => setActiveTab('quiz')} style={tabStyle('quiz')}>
          <BookOpen size={15} /> Quiz Verification ({quizQuestions.length})
        </button>
        <button type="button" onClick={() => setActiveTab('limits')} style={tabStyle('limits')}>
          <ShieldCheck size={15} /> Limits & Eligibility
        </button>
        <button type="button" onClick={() => setActiveTab('schedule')} style={tabStyle('schedule')}>
          <Calendar size={15} /> Scheduling
        </button>
      </div>

      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
        {error && (
          <div
            style={{
              padding: '12px 16px',
              borderRadius: 'var(--btn-radius)',
              backgroundColor: 'var(--badge-rose-bg)',
              color: 'var(--badge-rose-text)',
              fontSize: '13px',
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
            }}
          >
            <AlertCircle size={16} />
            <span>{error}</span>
          </div>
        )}

        {/* TAB 1: BASIC VIDEO & DETAILS */}
        {activeTab === 'basic' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {/* Auto Fetch Header Box */}
            <div
              style={{
                padding: '14px 18px',
                borderRadius: 'var(--card-radius)',
                backgroundColor: 'rgba(59, 130, 246, 0.08)',
                border: '1px solid rgba(59, 130, 246, 0.25)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                gap: '12px',
              }}
            >
              <div>
                <div style={{ fontWeight: '600', color: 'var(--primary)', fontSize: '13px' }}>
                  YouTube Video Task Upload & Auto-Config
                </div>
                <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                  Paste a video link. OpenRouter AI will fetch title, channel, HD thumbnail, and 8 SEO keywords.
                </div>
              </div>
            </div>

            <div>
              <label style={labelStyle}>Source URL</label>
              <div style={{ display: 'flex', gap: '10px' }}>
                <input
                  type="url"
                  required
                  value={sourceUrl}
                  onChange={(e) => handleUrlChange(e.target.value)}
                  placeholder="Paste YouTube link (e.g. https://www.youtube.com/watch?v=...)"
                  style={inputStyle}
                />
                <button
                  type="button"
                  onClick={() => handleFetchMetadata()}
                  disabled={loadingMeta || !sourceUrl}
                  style={{
                    padding: '10px 18px',
                    borderRadius: 'var(--btn-radius)',
                    backgroundColor: 'var(--primary)',
                    color: '#fff',
                    border: 'none',
                    fontWeight: '600',
                    fontSize: '13px',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '8px',
                    cursor: loadingMeta || !sourceUrl ? 'not-allowed' : 'pointer',
                    opacity: loadingMeta || !sourceUrl ? 0.6 : 1,
                    whiteSpace: 'nowrap',
                  }}
                >
                  <Sparkles size={16} className={loadingMeta ? 'animate-spin' : ''} />
                  {loadingMeta ? 'Fetching Info...' : 'Auto-Fetch Title & Data'}
                </button>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '6px' }}>
                  <label style={{ ...labelStyle, marginBottom: 0 }}>Video Title</label>
                  {title && !loadingMeta && (
                    <span style={{ fontSize: '11px', color: 'var(--badge-emerald-text)', fontWeight: '600' }}>
                      ✓ Auto-fetched from YouTube
                    </span>
                  )}
                  {loadingMeta && (
                    <span style={{ fontSize: '11px', color: 'var(--primary)', fontWeight: '600' }}>
                      Fetching Title...
                    </span>
                  )}
                </div>
                <input
                  type="text"
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="Auto-populated upon pasting video link"
                  style={inputStyle}
                />
              </div>
              <div>
                <label style={labelStyle}>Channel Name</label>
                <input
                  type="text"
                  value={channelName}
                  onChange={(e) => setChannelName(e.target.value)}
                  placeholder="e.g. AI Revolution"
                  style={inputStyle}
                />
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div>
                <label style={labelStyle}>YouTube Video ID</label>
                <input
                  type="text"
                  value={videoId}
                  onChange={(e) => setVideoId(e.target.value)}
                  placeholder="e.g. 2n7edISyRqg"
                  style={inputStyle}
                />
              </div>
              <div>
                <label style={labelStyle}>Thumbnail URL</label>
                <input
                  type="url"
                  value={thumbnailUrl}
                  onChange={(e) => setThumbnailUrl(e.target.value)}
                  placeholder="https://img.youtube.com/vi/..."
                  style={inputStyle}
                />
              </div>
            </div>

            {thumbnailUrl && (
              <div style={{ display: 'flex', alignItems: 'center', gap: '14px', padding: '10px', backgroundColor: 'var(--bg-tertiary)', borderRadius: 'var(--input-radius)' }}>
                <img
                  src={thumbnailUrl}
                  alt="Thumbnail Preview"
                  style={{ width: '120px', height: '68px', objectFit: 'cover', borderRadius: '6px' }}
                />
                <div>
                  <div style={{ fontSize: '13px', fontWeight: '600', color: 'var(--text-primary)' }}>{title || 'Video Preview'}</div>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>Channel: {channelName || 'YouTube Channel'}</div>
                </div>
              </div>
            )}

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div>
                <label style={labelStyle}>Task Type</label>
                <select value={taskType} onChange={(e) => setTaskType(e.target.value)} style={inputStyle}>
                  <option value="VIDEO">Video</option>
                  <option value="SURVEY">Survey</option>
                  <option value="SOCIAL">Social</option>
                  <option value="CHALLENGE">Challenge</option>
                </select>
              </div>
              <div>
                <label style={labelStyle}>Status</label>
                <select value={status} onChange={(e) => setStatus(e.target.value)} style={inputStyle}>
                  <option value="ACTIVE">Active (Live & Discoverable)</option>
                  <option value="DRAFT">Draft</option>
                  <option value="PAUSED">Paused</option>
                  <option value="EXHAUSTED">Exhausted</option>
                  <option value="EXPIRED">Expired</option>
                  <option value="ARCHIVED">Archived</option>
                </select>
              </div>
            </div>

            <div>
              <label style={labelStyle}>Description</label>
              <textarea
                rows={3}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Detailed description of what the user will learn from this video..."
                style={{ ...inputStyle, resize: 'vertical' }}
              />
            </div>
          </div>
        )}

        {/* TAB 2: AI & SEARCH KEYWORDS POOL */}
        {activeTab === 'ai' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
            <div
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '14px 18px',
                borderRadius: 'var(--card-radius)',
                backgroundColor: 'rgba(168, 85, 247, 0.08)',
                border: '1px solid rgba(168, 85, 247, 0.25)',
              }}
            >
              <div>
                <div style={{ fontWeight: '600', color: 'var(--accent-purple)', fontSize: '13px' }}>
                  AI & Search Keywords Pool (8 High-Ranking Phrases)
                </div>
                <div style={{ fontSize: '12px', color: 'var(--text-secondary)', marginTop: '2px' }}>
                  Generated using OpenRouter AI to ensure the target video appears in the first 2-5 search results.
                </div>
              </div>
              <button
                type="button"
                onClick={handleRegenerateKeywords}
                disabled={regeneratingKeywords || (!sourceUrl && !videoId)}
                style={{
                  padding: '8px 14px',
                  borderRadius: 'var(--btn-radius)',
                  backgroundColor: 'var(--bg-secondary)',
                  border: '1px solid var(--border-card)',
                  color: 'var(--accent-purple)',
                  fontSize: '12px',
                  fontWeight: '600',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px',
                  cursor: 'pointer',
                }}
              >
                <RefreshCw size={13} className={regeneratingKeywords ? 'animate-spin' : ''} />
                Regenerate AI Pool
              </button>
            </div>

            <div>
              <label style={labelStyle}>Primary Search Keywords (Default Target)</label>
              <input
                type="text"
                value={searchKeywords}
                onChange={(e) => setSearchKeywords(e.target.value)}
                placeholder="e.g. how to create vox style explainer video claude ai higgsfield"
                style={inputStyle}
              />
            </div>

            <div>
              <label style={labelStyle}>Add Keyword Phrase</label>
              <div style={{ display: 'flex', gap: '8px' }}>
                <input
                  type="text"
                  value={newKeywordInput}
                  onChange={(e) => setNewKeywordInput(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleAddKeyword(e)}
                  placeholder="Type search phrase and press Add..."
                  style={inputStyle}
                />
                <button
                  type="button"
                  onClick={handleAddKeyword}
                  style={{
                    padding: '10px 16px',
                    borderRadius: 'var(--btn-radius)',
                    backgroundColor: 'var(--bg-secondary)',
                    border: '1px solid var(--border-card)',
                    color: 'var(--text-primary)',
                    fontWeight: '600',
                    fontSize: '13px',
                    cursor: 'pointer',
                  }}
                >
                  + Add
                </button>
              </div>
            </div>

            <div>
              <label style={labelStyle}>Active Keywords Pool ({keywords.length} phrases)</label>
              {keywords.length === 0 ? (
                <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '13px', backgroundColor: 'var(--bg-tertiary)', borderRadius: 'var(--input-radius)' }}>
                  No keywords generated yet. Click "Auto-Fetch AI Data" or "Regenerate AI Pool".
                </div>
              ) : (
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px' }}>
                  {keywords.map((kw, idx) => (
                    <div
                      key={idx}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '6px',
                        padding: '6px 12px',
                        borderRadius: '20px',
                        backgroundColor: 'var(--bg-tertiary)',
                        border: '1px solid var(--border-card)',
                        fontSize: '12px',
                        color: 'var(--text-primary)',
                      }}
                    >
                      <span>🔍 {kw}</span>
                      <button
                        type="button"
                        onClick={() => handleRemoveKeyword(idx)}
                        style={{
                          background: 'none',
                          border: 'none',
                          color: 'var(--text-muted)',
                          cursor: 'pointer',
                          padding: '0 2px',
                        }}
                      >
                        <X size={13} />
                      </button>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        )}

        {/* TAB 3: REWARDS & WATCH TIME */}
        {activeTab === 'reward' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div>
                <label style={labelStyle}>Reward Type Rule</label>
                <select value={rewardType} onChange={(e) => setRewardType(e.target.value)} style={inputStyle}>
                  <option value="target">🎯 Target Threshold (Lump sum at X seconds)</option>
                  <option value="per_time">⏱️ Time-Based (Coins incrementally per X seconds)</option>
                  <option value="watch_all">✅ Completion-Based (100% full video required)</option>
                </select>
              </div>

              {rewardType === 'per_time' && (
                <div>
                  <label style={labelStyle}>Interval Seconds (Rate)</label>
                  <input
                    type="number"
                    min="5"
                    value={intervalSeconds}
                    onChange={(e) => setIntervalSeconds(Number(e.target.value))}
                    placeholder="60"
                    style={inputStyle}
                  />
                  <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>e.g. Award coins every 60 seconds watched</span>
                </div>
              )}

              {rewardType === 'target' && (
                <div>
                  <label style={labelStyle}>Target Watch Seconds</label>
                  <input
                    type="number"
                    min="5"
                    value={targetSeconds}
                    onChange={(e) => {
                      setTargetSeconds(Number(e.target.value));
                      setRequiredWatchSeconds(Number(e.target.value));
                    }}
                    placeholder="60"
                    style={inputStyle}
                  />
                  <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>e.g. Watch 60 seconds to earn reward</span>
                </div>
              )}

              {rewardType === 'watch_all' && (
                <div>
                  <label style={labelStyle}>Total Video Duration (Seconds)</label>
                  <input
                    type="number"
                    min="10"
                    value={requiredWatchSeconds}
                    onChange={(e) => setRequiredWatchSeconds(Number(e.target.value))}
                    placeholder="300"
                    style={inputStyle}
                  />
                  <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>User must watch full video length</span>
                </div>
              )}
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '16px' }}>
              <div>
                <label style={labelStyle}>Reward Coins</label>
                <div style={{ position: 'relative' }}>
                  <input
                    type="number"
                    min="0"
                    value={rewardCoins}
                    onChange={(e) => setRewardCoins(Number(e.target.value))}
                    style={inputStyle}
                  />
                </div>
              </div>

              <div>
                <label style={labelStyle}>Reward Cash (Fiat USD)</label>
                <input
                  type="text"
                  value={rewardCash}
                  onChange={(e) => setRewardCash(e.target.value)}
                  placeholder="0.00"
                  style={inputStyle}
                />
              </div>

              <div>
                <label style={labelStyle}>Reward XP</label>
                <input
                  type="number"
                  min="0"
                  value={rewardXp}
                  onChange={(e) => setRewardXp(Number(e.target.value))}
                  placeholder="25"
                  style={inputStyle}
                />
              </div>
            </div>

            <div>
              <label style={labelStyle}>Required Watch Seconds (System Gate)</label>
              <input
                type="number"
                min="1"
                value={requiredWatchSeconds}
                onChange={(e) => setRequiredWatchSeconds(Number(e.target.value))}
                style={inputStyle}
              />
              <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>
                Minimum watch duration ({Math.round(requiredWatchSeconds / 60)} minutes) required before server allows reward verification.
              </span>
            </div>
          </div>
        )}

        {/* TAB 4: QUIZ VERIFICATION */}
        {activeTab === 'quiz' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
            <div
              style={{
                display: 'flex',
                justifyContent: 'space-between',
                alignItems: 'center',
                padding: '14px 18px',
                borderRadius: 'var(--card-radius)',
                backgroundColor: 'var(--bg-tertiary)',
                border: '1px solid var(--border-card)',
              }}
            >
              <label style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }}>
                <input
                  type="checkbox"
                  checked={quizRequired}
                  onChange={(e) => setQuizRequired(e.target.checked)}
                  style={{ width: '18px', height: '18px', accentColor: 'var(--primary)' }}
                />
                <div>
                  <div style={{ fontWeight: '600', color: 'var(--text-primary)', fontSize: '13px' }}>
                    Quiz Verification Required
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                    Users must pass a quiz after watching the video to claim their coin reward.
                  </div>
                </div>
              </label>

              {quizRequired && (
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <label style={{ fontSize: '12px', color: 'var(--text-secondary)', fontWeight: '600' }}>Pass %:</label>
                  <input
                    type="number"
                    min="1"
                    max="100"
                    value={quizPassPercentage}
                    onChange={(e) => setQuizPassPercentage(Number(e.target.value))}
                    style={{ width: '70px', ...inputStyle }}
                  />
                </div>
              )}
            </div>

            {quizRequired && (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div style={{ fontWeight: '600', color: 'var(--text-primary)', fontSize: '13px' }}>
                    Quiz Questions ({quizQuestions.length})
                  </div>
                  <button
                    type="button"
                    onClick={handleAddQuizQuestion}
                    style={{
                      padding: '6px 12px',
                      borderRadius: 'var(--btn-radius)',
                      backgroundColor: 'var(--primary)',
                      color: '#fff',
                      border: 'none',
                      fontSize: '12px',
                      fontWeight: '600',
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '6px',
                    }}
                  >
                    <Plus size={14} /> Add Question
                  </button>
                </div>

                {quizQuestions.length === 0 ? (
                  <div style={{ padding: '24px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '13px', backgroundColor: 'var(--bg-tertiary)', borderRadius: 'var(--input-radius)' }}>
                    No quiz questions added yet. Click "+ Add Question" above.
                  </div>
                ) : (
                  quizQuestions.map((q, qIdx) => (
                    <div
                      key={qIdx}
                      style={{
                        padding: '16px',
                        borderRadius: 'var(--input-radius)',
                        backgroundColor: 'var(--bg-tertiary)',
                        border: '1px solid var(--border-card)',
                        display: 'flex',
                        flexDirection: 'column',
                        gap: '12px',
                      }}
                    >
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <span style={{ fontSize: '13px', fontWeight: '700', color: 'var(--primary)' }}>
                          Question #{qIdx + 1}
                        </span>
                        <button
                          type="button"
                          onClick={() => handleRemoveQuizQuestion(qIdx)}
                          style={{ background: 'none', border: 'none', color: 'var(--badge-rose-text)', cursor: 'pointer' }}
                        >
                          <Trash2 size={15} />
                        </button>
                      </div>

                      <input
                        type="text"
                        value={q.question_text || ''}
                        onChange={(e) => handleUpdateQuizQuestion(qIdx, 'question_text', e.target.value)}
                        placeholder="Type question text..."
                        style={inputStyle}
                      />

                      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                        {(q.options || ['A', 'B', 'C', 'D']).map((opt, optIdx) => (
                          <div key={optIdx} style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <input
                              type="radio"
                              name={`correct_${qIdx}`}
                              checked={q.correct_answer === opt}
                              onChange={() => handleUpdateQuizQuestion(qIdx, 'correct_answer', opt)}
                              title="Set as correct answer"
                            />
                            <input
                              type="text"
                              value={opt}
                              onChange={(e) => handleUpdateQuizOption(qIdx, optIdx, e.target.value)}
                              placeholder={`Option ${optIdx + 1}`}
                              style={{ ...inputStyle, padding: '6px 10px', fontSize: '12px' }}
                            />
                          </div>
                        ))}
                      </div>

                      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                        <input
                          type="text"
                          value={q.correct_answer || ''}
                          onChange={(e) => handleUpdateQuizQuestion(qIdx, 'correct_answer', e.target.value)}
                          placeholder="Correct Answer string"
                          style={{ ...inputStyle, fontSize: '12px' }}
                        />
                        <input
                          type="text"
                          value={q.explanation || ''}
                          onChange={(e) => handleUpdateQuizQuestion(qIdx, 'explanation', e.target.value)}
                          placeholder="Explanation for correct answer..."
                          style={{ ...inputStyle, fontSize: '12px' }}
                        />
                      </div>
                    </div>
                  ))
                )}
              </div>
            )}
          </div>
        )}

        {/* TAB 5: LIMITS & ELIGIBILITY */}
        {activeTab === 'limits' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div>
                <label style={labelStyle}>Daily User Limit</label>
                <input
                  type="number"
                  min="1"
                  value={dailyUserLimit}
                  onChange={(e) => setDailyUserLimit(Number(e.target.value))}
                  style={inputStyle}
                />
                <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Max completions per user per day (default 1)</span>
              </div>

              <div>
                <label style={labelStyle}>Total Campaign Capacity (Global Limit)</label>
                <input
                  type="number"
                  min="1"
                  value={totalCompletionLimit}
                  onChange={(e) => setTotalCompletionLimit(e.target.value)}
                  placeholder="Unlimited (e.g. 500)"
                  style={inputStyle}
                />
                <span style={{ fontSize: '11px', color: 'var(--text-muted)' }}>Leave blank for infinite task capacity</span>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '16px' }}>
              <div>
                <label style={labelStyle}>Minimum User Level</label>
                <input
                  type="number"
                  min="1"
                  value={minimumLevel}
                  onChange={(e) => setMinimumLevel(Number(e.target.value))}
                  style={inputStyle}
                />
              </div>

              <div>
                <label style={labelStyle}>Minimum Trust Score (0-100)</label>
                <input
                  type="number"
                  min="0"
                  max="100"
                  value={minimumTrustScore}
                  onChange={(e) => setMinimumTrustScore(Number(e.target.value))}
                  style={inputStyle}
                />
              </div>

              <div>
                <label style={labelStyle}>Total Completions (Counter)</label>
                <input
                  type="number"
                  disabled
                  value={totalCompletions}
                  style={{ ...inputStyle, opacity: 0.7 }}
                />
              </div>
            </div>

            <div style={{ padding: '14px 18px', borderRadius: 'var(--input-radius)', backgroundColor: 'var(--bg-tertiary)', border: '1px solid var(--border-card)' }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }}>
                <input
                  type="checkbox"
                  checked={verificationRequired}
                  onChange={(e) => setVerificationRequired(e.target.checked)}
                  style={{ width: '18px', height: '18px', accentColor: 'var(--primary)' }}
                />
                <div>
                  <div style={{ fontWeight: '600', color: 'var(--text-primary)', fontSize: '13px' }}>
                    Require Identity Verification (KYC)
                  </div>
                  <div style={{ fontSize: '12px', color: 'var(--text-secondary)' }}>
                    Only verified users will be permitted to access and earn from this campaign.
                  </div>
                </div>
              </label>
            </div>
          </div>
        )}

        {/* TAB 6: SCHEDULING & METADATA */}
        {activeTab === 'schedule' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                  <label style={{ ...labelStyle, marginBottom: 0 }}>Starts At</label>
                  <button type="button" onClick={() => setNow(setStartsAt)} style={{ background: 'none', border: 'none', color: 'var(--primary)', fontSize: '11px', cursor: 'pointer', fontWeight: '600' }}>
                    Set Now
                  </button>
                </div>
                <input
                  type="datetime-local"
                  value={startsAt}
                  onChange={(e) => setStartsAt(e.target.value)}
                  style={inputStyle}
                />
              </div>

              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                  <label style={{ ...labelStyle, marginBottom: 0 }}>Expires At</label>
                  <button type="button" onClick={() => setNow(setExpiresAt)} style={{ background: 'none', border: 'none', color: 'var(--primary)', fontSize: '11px', cursor: 'pointer', fontWeight: '600' }}>
                    Set Now
                  </button>
                </div>
                <input
                  type="datetime-local"
                  value={expiresAt}
                  onChange={(e) => setExpiresAt(e.target.value)}
                  style={inputStyle}
                />
              </div>
            </div>

            {task && (
              <div style={{ padding: '16px', borderRadius: 'var(--input-radius)', backgroundColor: 'var(--bg-tertiary)', border: '1px solid var(--border-card)', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', fontSize: '12px', color: 'var(--text-secondary)' }}>
                <div>
                  <span style={{ fontWeight: '600', color: 'var(--text-primary)' }}>Created By:</span> {createdByEmail || 'Admin Superuser'}
                </div>
                <div>
                  <span style={{ fontWeight: '600', color: 'var(--text-primary)' }}>Task Slug:</span> {task.slug || 'N/A'}
                </div>
                <div>
                  <span style={{ fontWeight: '600', color: 'var(--text-primary)' }}>Created At:</span> {createdAt ? new Date(createdAt).toLocaleString() : 'N/A'}
                </div>
                <div>
                  <span style={{ fontWeight: '600', color: 'var(--text-primary)' }}>Last Updated:</span> {updatedAt ? new Date(updatedAt).toLocaleString() : 'N/A'}
                </div>
              </div>
            )}
          </div>
        )}

        {/* Footer Actions */}
        <div
          style={{
            display: 'flex',
            justifyContent: 'flex-end',
            gap: '12px',
            borderTop: '1px solid var(--border-card)',
            paddingTop: '16px',
            marginTop: '8px',
          }}
        >
          <button
            type="button"
            onClick={onClose}
            style={{
              padding: '10px 18px',
              borderRadius: 'var(--btn-radius)',
              backgroundColor: 'var(--bg-secondary)',
              border: '1px solid var(--border-card)',
              color: 'var(--text-primary)',
              fontWeight: '600',
              fontSize: '13px',
              cursor: 'pointer',
            }}
          >
            Cancel
          </button>
          <button
            type="submit"
            disabled={saving}
            style={{
              padding: '10px 24px',
              borderRadius: 'var(--btn-radius)',
              backgroundColor: 'var(--primary)',
              border: 'none',
              color: '#fff',
              fontWeight: '600',
              fontSize: '13px',
              cursor: saving ? 'not-allowed' : 'pointer',
              opacity: saving ? 0.6 : 1,
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
            }}
          >
            {saving ? 'Saving Task...' : task ? 'Save Changes' : 'Create Video Task'}
          </button>
        </div>
      </form>
    </Modal>
  );
}
