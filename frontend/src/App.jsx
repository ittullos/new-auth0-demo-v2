import { useAuth0 } from '@auth0/auth0-react'
import { LoginButton } from './components/LoginButton'
import { ProfilePage } from './pages/ProfilePage'

function LandingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-indigo-50 flex items-center justify-center p-4">
      <div className="text-center max-w-sm w-full">
        <div className="mb-8">
          <div className="inline-flex items-center justify-center w-16 h-16 bg-indigo-600 rounded-2xl shadow-lg mb-4">
            <svg className="w-8 h-8 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
            </svg>
          </div>
          <h1 className="text-3xl font-bold text-slate-800">Auth0 Demo</h1>
          <p className="text-slate-500 mt-2 text-sm">
            Sign in to view your profile and API token.
          </p>
        </div>
        <LoginButton />
      </div>
    </div>
  )
}

function LoadingScreen() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 to-indigo-50 flex items-center justify-center">
      <div className="flex flex-col items-center gap-3">
        <div className="w-10 h-10 border-4 border-indigo-200 border-t-indigo-600 rounded-full animate-spin" />
        <p className="text-slate-500 text-sm">Loading…</p>
      </div>
    </div>
  )
}

export default function App() {
  const { isLoading, isAuthenticated } = useAuth0()

  if (isLoading) return <LoadingScreen />
  if (isAuthenticated) return <ProfilePage />
  return <LandingPage />
}
