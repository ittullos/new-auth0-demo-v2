export function Avatar({ picture, name }) {
  if (picture) {
    return (
      <img
        src={picture}
        alt={name || 'User avatar'}
        className="w-20 h-20 rounded-full ring-4 ring-indigo-100 shadow-md object-cover"
      />
    )
  }

  const initials = name
    ? name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()
    : '?'

  return (
    <div className="w-20 h-20 rounded-full ring-4 ring-indigo-100 shadow-md bg-indigo-600 flex items-center justify-center text-white text-2xl font-bold select-none">
      {initials}
    </div>
  )
}
