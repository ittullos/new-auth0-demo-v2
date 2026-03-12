import { useAuth0 } from '@auth0/auth0-react'
import { Avatar } from '../components/Avatar'
import { LogoutButton } from '../components/LogoutButton'
import { useProfile } from '../hooks/useProfile'

function LoadingSpinner() {
  return (
    <div className="flex flex-col items-center gap-3 py-12">
      <div className="w-10 h-10 border-4 border-indigo-200 border-t-indigo-600 rounded-full animate-spin" />
      <p className="text-slate-500 text-sm">Loading your profile…</p>
    </div>
  )
}

function UnauthorizedError() {
  return (
    <div className="flex flex-col items-center gap-4 py-10 px-6 bg-red-50 rounded-2xl border border-red-100 text-center max-w-sm mx-auto">
      <div className="text-4xl" aria-hidden="true">🔒</div>
      <div>
        <p className="font-semibold text-red-700">Access denied</p>
        <p className="text-red-500 text-sm mt-1">
          Your session is invalid or expired. Please log out and log in again.
        </p>
      </div>
      <LogoutButton />
    </div>
  )
}

function GenericError({ message }) {
  return (
    <div className="py-8 px-6 bg-amber-50 rounded-2xl border border-amber-100 text-center max-w-sm mx-auto">
      <p className="font-semibold text-amber-700">Something went wrong</p>
      <p className="text-amber-600 text-sm mt-1">{message}</p>
    </div>
  )
}

export function ProfilePage() {
  const { user } = useAuth0()
  const { profile, token, loading, error } = useProfile()

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-indigo-50 flex items-center justify-center p-4">
      <div className="w-full max-w-lg bg-white rounded-3xl shadow-xl overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-indigo-600 to-indigo-500 px-8 py-6 flex items-center justify-between">
          <h1 className="text-white font-bold text-xl tracking-tight">My Profile</h1>
          <LogoutButton />
        </div>

        <div className="px-8 py-8 flex flex-col gap-8">
          {/* Avatar + identity from Auth0 SDK (id_token) */}
          <div className="flex items-center gap-5">
            <Avatar picture={user?.picture} name={user?.name} />
            <div>
              <p className="text-lg font-semibold text-slate-800">{user?.name || '—'}</p>
              <p className="text-sm text-slate-500">{user?.email || '—'}</p>
              <p className="text-xs text-slate-400 mt-0.5 font-mono">{user?.sub}</p>
            </div>
          </div>

          {/* API response section */}
          <div>
            <h2 className="text-xs font-semibold text-slate-400 uppercase tracking-widest mb-3">
              API Response <span className="font-normal normal-case text-slate-300">· GET /profile</span>
            </h2>

            {loading && <LoadingSpinner />}

            {!loading && error?.type === 'unauthorized' && <UnauthorizedError />}
            {!loading && error?.type === 'unknown' && <GenericError message={error.message} />}

            {!loading && !error && profile && (
              <pre className="bg-slate-50 border border-slate-100 rounded-xl p-4 text-xs text-slate-700 font-mono overflow-x-auto whitespace-pre-wrap break-all">
                {JSON.stringify(profile, null, 2)}
              </pre>
            )}
          </div>

          {/* Access token */}
          {token && (
            <div>
              <h2 className="text-xs font-semibold text-slate-400 uppercase tracking-widest mb-3">
                Access Token
              </h2>
              <pre className="bg-slate-50 border border-slate-100 rounded-xl p-4 text-xs text-slate-500 font-mono overflow-x-auto whitespace-pre-wrap break-all">
                {token}
              </pre>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
