# Universal UI/UX Design System + Frontend Architecture Blueprint

This document abstracts the existing frontend into a reusable visual system and frontend architecture for business web applications. It intentionally separates domain data from layout, component behavior, styling, responsive rules, and implementation structure.

All dimensions, colors, typography, transitions, and component behaviors below are preserved from the inspected source. Where the source does not establish a value or rule, this document says so rather than inventing one.

## 1. System Intent

The visual language is an operational, desktop-first administration interface:

- off-white application canvas;
- white or dark-green surfaces;
- green primary actions and active states;
- gold secondary accent;
- compact uppercase controls and headings;
- dense tables and forms;
- restrained shadows and visible borders;
- responsive stacking rather than a separate mobile information architecture;
- predictable create, edit, view, delete, loading, empty, and error states.

The design is suitable for any application that manages authenticated users, records, metrics, workflows, permissions, reports, and related detail pages. Domain content, labels, statuses, navigation names, and API contracts are variables supplied by the application built on top of this system.

## 2. Technology and Frontend Architecture

| Concern | Existing implementation to reproduce |
|---|---|
| Framework | Next.js App Router with TypeScript |
| Styling | Tailwind CSS v4 imports plus CSS variables and utility classes |
| Component primitives | shadcn/ui-style components wrapping Radix UI primitives |
| Icons | `lucide-react`, predominantly outlined icons |
| Tables | TanStack Table composed with a shadcn Table |
| Forms | React Hook Form with Zod resolvers |
| Server state | TanStack Query |
| Client state | Zustand; persisted state is used for shell controls and authentication |
| Theme | `next-themes`; light default, system theme enabled |
| Toasts | Sonner, exposed through local success/error/info/warning helpers |
| Error handling | API error parsing plus centralized user-facing toast helpers |
| Data access | Central API client/data-source abstraction and feature query hooks |
| CSS entry point | `app/globals.css` relative to the frontend application root |

The repository rule in `AGENTS.md` requires reuse of existing shadcn primitives from `@/components/ui/*`, Tailwind utilities, React Hook Form/Zod for forms, shadcn Table/TanStack Table for data tables, and composition instead of parallel custom primitives.

### Provider order

The root layout establishes this nesting order:

```text
ThemeProvider
└── AuthProvider
    └── SidebarProvider
        └── QueryProvider
            ├── route content
            └── Toaster position="top-right" richColors
```

The body uses `min-h-screen`, the application background token, primary text, antialiasing, and `overflow-hidden`.

### Recommended reusable project structure

Use this structure when building a new application with the same architecture. Domain names can be added beneath `features/` without changing the shell or primitives.

```text
app/
  (auth)/
    login/page.tsx
  (application)/
    layout.tsx
    dashboard/page.tsx
    records/page.tsx
    records/[id]/page.tsx
    settings/page.tsx
  print/
components/
  ui/                 # shadcn/Radix primitives
  layout/             # sidebar, topbar, breadcrumbs, user menu
  shared/             # empty, error, loading, status, detail header
  forms/              # DrawerForm and controlled field composites
  tables/             # DataTable, toolbar, pagination, row actions
  dashboard/          # metric and visualization widgets
  features/           # domain-specific composites only
constants/
features/
  records/
    hooks/
    schemas/
    utils/
hooks/
lib/
providers/
store/
types/
public/
```

## 3. Application Shell

The authenticated shell is a full-height flex layout:

```text
Application Shell
├── Fixed Navigation Sidebar
└── Flexible Application Area
    ├── Sticky Topbar
    └── Scrollable Main Content
```

### Shell measurements

| Property | Existing value |
|---|---|
| Outer shell | `h-screen w-full` |
| Expanded sidebar offset | `ml-[var(--tf-sidebar-width)]` = `240px` |
| Collapsed sidebar offset | `ml-[var(--tf-sidebar-collapsed-width)]` = `64px` |
| Sidebar transition | `duration-300 ease-out` |
| Topbar height | `var(--tf-topbar-height)` = `60px` |
| Main content | `flex-1 overflow-y-auto bg-[var(--tf-bg)] p-6` |
| Main horizontal padding | `24px` through `p-6` |
| Main universal max-width | None established; content uses the available shell width |
| Body overflow | `overflow-hidden`; scrolling is delegated to the main area |

The source does not establish a universal authenticated content `max-width`. Do not add one by default. Individual document or authentication views may have their own max-width.

The application layout waits for authentication and persisted shell state before rendering the full shell. It shows a centered loading spinner while authentication is unresolved, redirects unauthenticated users to the authentication route, and wraps application children in an error boundary.

## 4. Page Composition Rules

The dominant page rhythm is a vertical `space-y-6` stack. The common page composition is:

```text
Page
├── Page Header / Context Band
│   ├── Title
│   ├── Description or context
│   └── Actions / filters
├── Major content sections separated by 24px
├── Cards, panels, tables, charts, or forms
└── Drawers/dialogs rendered alongside page content
```

### Common page values

| Pattern | Existing implementation |
|---|---|
| Major vertical rhythm | `space-y-6` / `gap-6` |
| Page header surface | `bg-tf-surface p-6 rounded-xl border border-tf-border shadow-sm` |
| Page header layout | `flex flex-col sm:flex-row sm:items-center justify-between gap-4` |
| Two-column section | `grid grid-cols-1 lg:grid-cols-2 gap-6` |
| Three-column section | `grid grid-cols-1 lg:grid-cols-3 gap-6` |
| Two-thirds/one-third section | `lg:col-span-2` plus `lg:col-span-1` |
| Responsive form grid | `grid grid-cols-1 md:grid-cols-2 gap-4` or `gap-6` |
| Detail metadata | `grid-cols-2 md:grid-cols-3/4 gap-6` |
| Detail page lower padding | `pb-12` is commonly used |
| Header/action alignment | Title/context left, action controls right at `sm` and above |
| Narrow-screen behavior | Header and action controls stack vertically |

### Page header

The canonical page header is a bordered surface with `p-6`, `rounded-xl`, `shadow-sm`, and a `1px` token border. Its title commonly uses `.tf-h2`; supporting text uses `.tf-body` with a muted/secondary text token and a small top margin. Primary actions appear in the same responsive flex row.

### Dashboard template

```text
Page with space-y-6
├── Header/context band with date/filter control
├── Metric card row
├── Primary visualization + secondary visualization
├── Two secondary panels
└── Full-width recent-activity/data table
```

The source dashboard uses `grid-cols-1 lg:grid-cols-3 gap-6` for a two-thirds primary panel and one-third secondary panel, followed by `grid-cols-1 lg:grid-cols-2 gap-6 items-stretch`. Each widget is isolated with an `ErrorBoundary`. Background refresh dims the existing content with `opacity-50 pointer-events-none` instead of removing it.

### List template

```text
Page with space-y-6
├── Header/context band
│   ├── Page title and description
│   └── Permission-gated primary action
├── Surface containing DataTable
│   ├── Search/filter toolbar
│   ├── Table
│   └── Pagination
└── Create/edit DrawerForm
```

A list page should define its columns, query/mutation hooks, permission checks, empty state, and form schema locally while reusing `DataTable`, `DrawerForm`, field composites, status badges, and toast helpers.

### Detail template

```text
Page with space-y-6 and often pb-12
├── DetailHeader
│   ├── Circular back control
│   ├── Title and context
│   └── Actions
├── Responsive summary cards/grid
├── Tabs or additional information panels
├── Related data
└── Feature-specific drawers where required
```

Detail layouts commonly use `grid-cols-1 lg:grid-cols-3 gap-6`, with a two-thirds primary information surface and one-third supporting summary surface. Information is displayed through compact label/value pairs. Labels commonly use muted `text-xs uppercase tracking-wider`; values use medium or semibold primary text.

### Form template

```text
Drawer or page
├── Form header/context
├── Form sections separated by space-y-8
│   ├── Section heading
│   └── Responsive field grid
├── Inline descriptions and validation messages
└── Cancel and submit actions in a footer
```

### Settings/template variations

The source has both a consolidated tabbed settings view and standalone settings subroutes. Treat a tabbed settings view and route-based settings view as optional composition choices, not as two competing primitives. The tab implementation wraps the tab list in a surface with `p-1`, border, `rounded-lg`, and responsive wrapping.

## 5. Navigation Sidebar

Primary implementation references, relative to the frontend root:

- `components/layout/Sidebar.tsx`
- `components/layout/SidebarNav.tsx`
- `components/layout/SidebarItem.tsx`
- `store/sidebar.store.ts`
- `components/ui/tooltip.tsx`

### Dimensions and structure

```text
Sidebar
├── Logo area and collapse control
├── Optional context switcher area
├── Scrollable navigation
│   └── Navigation groups
│       └── Navigation items
└── Current user/profile and secondary action
```

| Property | Existing value |
|---|---|
| Position | `fixed left-0 top-0` |
| Layer | `z-40` |
| Height | `h-screen` |
| Expanded width | `240px` |
| Collapsed width | `64px` |
| Background | Light `#ffffff`; dark `#18201a` |
| Right border | `1px`, `--tf-border` |
| Width transition | `transition-all duration-300 ease-out` |
| Logo area height | `60px` |
| Logo area padding | `px-4` = `16px` horizontal |
| Navigation wrapper | `flex-1 overflow-y-auto overflow-x-hidden py-4` |
| Navigation horizontal padding | `px-3` = `12px` |
| Navigation group separation | `gap-6` = `24px` |
| Item group separation | `gap-1` = `4px` |
| Open item padding | `px-3 py-2.5` = `12px` horizontal, `10px` vertical |
| Open item icon/text gap | `gap-3` = `12px` |
| Collapsed item padding | `py-2.5 px-0` |
| Navigation icon | `h-5 w-5` = `20px` |
| Item radius | `rounded-lg` utility |
| Item transition | `duration-200 ease-out` |
| Collapsed tooltip delay | `100ms` |
| Profile area | `border-t`, `p-4` = `16px` |

### Logo and collapse behavior

The logo row is the same `60px` height as the topbar. In expanded mode it shows the application mark/name and a `size-7` collapse control. In collapsed mode, the logo is centered and a separate expand control appears in a bordered `p-2` row. The application mark uses a `32px` rounded tile when an image asset is unavailable.

The open/collapsed state is persisted in Zustand under the source storage name `tf-sidebar-storage`; the default is open. The hydration provider temporarily renders its wrapper invisible until persisted state is available.

### Navigation item states

| State | Existing treatment |
|---|---|
| Normal | `text-[var(--tf-sidebar-text)]` |
| Hover | `hover:bg-tf-surface-2` |
| Active expanded | Soft primary background, active text, `font-semibold`, `3px` left accent border, `rounded-l-none`, adjusted left padding `pl-[9px]` |
| Active collapsed | Same soft background and `3px` left accent border; label hidden |
| Badge | Full pill, primary background, white `10px` bold text, `px-2 py-0.5` |
| Disabled | No explicit sidebar disabled class is established |
| Nested item | No generic nested navigation tree is implemented |

Navigation groups are generic containers with an overline label. Group labels use `.tf-overline`, muted text, `11px`, weight `600`, `1.3` line-height, `0.08em` letter spacing, and uppercase transformation.

### Collapsed mode and tooltip

Collapsed items expose an `aria-label` and render a Radix Tooltip on the right. The tooltip uses a `100ms` delay, `side="right"`, `sideOffset={15}`, primary background, white text, a primary border, `text-sm font-medium`, and `shadow-md`.

### User profile area

The bottom profile area uses a top border and `p-4`. The avatar/initials container is `36px`, circular, surface-2 background, border, centered text, and semibold weight. Expanded mode displays the current user's name and a muted role/context line, plus an icon-only danger secondary action. Collapsed mode centers only the avatar/initials.

### Responsive behavior

The topbar mobile menu control is visible below `lg` and toggles the same sidebar store. The sidebar remains a fixed sidebar; no separate mobile overlay/sidebar implementation was found. Reproduce this behavior unless a deliberate product requirement changes it.

## 6. Header / Topbar

Primary reference: `components/layout/Topbar.tsx`.

| Property | Existing value |
|---|---|
| Element | `header` |
| Position | `sticky top-0` |
| Layer | `z-30` |
| Height | `60px` |
| Padding | `px-4 sm:px-6` = `16px` / `24px` horizontal |
| Background | Light `#ffffff`; dark `#18201a` |
| Border | Bottom `1px` `--tf-border` |
| Shadow | `shadow-sm` |
| Main layout | `flex items-center gap-4` |
| Right control gap | `gap-1 sm:gap-2` |
| Mobile menu | `lg:hidden` |
| Breadcrumbs | `hidden sm:block` |
| Focus control | `hidden sm:flex` |

```text
Topbar
├── Left group
│   ├── Mobile menu icon control
│   └── Breadcrumbs/page context
├── Flexible center group
│   └── Global search/command control
└── Right group
    ├── Focus/working-space control
    ├── Notification control
    ├── Theme control
    └── User menu/avatar
```

Breadcrumb labels are derived from the current pathname. The header does not use a separate page title slot in the inspected implementation; page titles are normally rendered in the page body/header band.

The search/command control is centered responsively and can expose navigation and quick-create actions. The focus control collapses the sidebar. The theme control waits for client mount to avoid hydration mismatch. The user menu is an avatar trigger with a dropdown containing identity, settings, and sign-out actions.

## 7. Main Content and Containers

The main area is not a centered marketing canvas. It is a full available-width work surface with `p-6`, vertical scrolling, and a muted application background. Page content controls its own grid and surface widths.

Use these relationships:

```text
Sidebar width
└── offsets flexible shell with matching left margin
    Topbar width fills remaining shell
    Main width fills remaining shell
    Main p-6 creates the page edge
    Page sections define their own cards/grids
```

Do not add a universal content max-width, outer decorative background, or nested card shells unless a specific existing pattern requires it. Print/document views are a separate surface family and may use white backgrounds, black text, internal padding, and document max-widths.

## 8. Typography System

Fonts are loaded with `next/font/google` in `app/layout.tsx`:

| Font | Loaded weights | CSS variable | Role |
|---|---:|---|---|
| IBM Plex Sans | 500, 600, 700 | `--font-ibm-plex-sans` | Heading stack |
| Inter | 400, 500, 600 | `--font-inter` | Body stack |
| Roboto | 400, 500 | `--font-roboto` | Body fallback |
| JetBrains Mono | 500 | `--font-jetbrains-mono` | Technical values/identifiers |

The heading stack is `var(--font-ibm-plex-sans), var(--font-roboto), var(--font-inter), sans-serif`. The body stack is `var(--font-inter), var(--font-roboto), sans-serif`. The monospace stack is `var(--font-jetbrains-mono), ui-monospace, monospace`. The global HTML element uses the body stack.

### Typography scale

| Token/class | Size | Weight | Line height | Letter spacing | Usage |
|---|---:|---:|---:|---:|---|
| `.tf-display` | 48px | 700 | 1.1 | `-0.02em` | Large display heading |
| `.tf-h1` | 32px | 700 | 1.2 | `-0.015em` | Major heading/auth heading |
| `.tf-h2` | 24px | 700 | 1.25 | `-0.01em` | Page/detail title |
| `.tf-h3` | 20px | 600 | 1.3 | default | Section/empty heading |
| `.tf-h4` | 16px | 600 | 1.4 | default | Compact heading |
| `.tf-body-lg` | 16px | 400 | 1.6 | default | Large body |
| `.tf-body` | 14px | 400 | 1.6 | default | Standard body/context |
| `.tf-body-sm` | 13px | 400 | 1.5 | default | Compact body/navigation |
| `.tf-caption` | 12px | 500 | 1.4 | `0.02em` | Supporting text |
| `.tf-overline` | 11px | 600 | 1.3 | `0.08em` | Uppercase group labels |
| `.tf-mono` | 13px | 500 | 1.5 | default | IDs/technical values |
| `.tf-kpi-value` | 36px | 700 | 1 | `-0.02em` | Primary metric value |
| `.tf-kpi-value-sm` | 28px | 700 | 1 | default | Smaller metric value |

Card titles from the shadcn Card primitive use heading font, `text-lg`, semibold, uppercase, and `tracking-wider`. Button defaults use `text-xs`, semibold, uppercase, and `tracking-widest`; many workflow controls explicitly override that with `normal-case tracking-normal`.

## 9. Color System

The source has two color layers: shadcn semantic OKLCH variables and a custom source-prefixed token family. The source-prefixed aliases should be mapped into semantic names in a new application. Preserve the values when visual fidelity is required.

### Semantic/base tokens

| Semantic role | Light value | Dark value |
|---|---|---|
| Application background | `#f7f8f4` | `#0f1511` |
| Surface | `#ffffff` | `#18201a` |
| Surface secondary | `#f2f5ef` | `#202b22` |
| Primary brand color | `#2f6b3b` | `#62b46d` |
| Primary brand hover | `#255730` | `#7bc684` |
| Primary soft | `#eef7f0` | `rgba(98, 180, 109, 0.14)` |
| Accent color | `#c79b2d` | `#d6b04a` |
| Accent hover | `#ad8522` | `#e2bf66` |
| Accent soft | `#fff8e5` | `rgba(214, 176, 74, 0.12)` |
| Success | `#16a34a` | `#4ade80` |
| Warning | `#d97706` | `#fbbf24` |
| Danger/error | `#dc2626` | `#f87171` |
| Info | `#2563eb` | `#60a5fa` |
| Border | `#dde5dc` | `rgba(255, 255, 255, 0.08)` |
| Strong border | `#c7d2c5` | `rgba(255, 255, 255, 0.15)` |
| Primary text | `#1b1f1c` | `#f3f5f3` |
| Secondary text | `#4b5563` | `#c3cbc4` |
| Muted text | `#6b7280` | `#7c8a80` |
| Inverse text | `#ffffff` | `#111827` |

### Source-prefixed aliases

The existing implementation names the semantic values with a `--tf-` prefix and exposes corresponding Tailwind names such as `bg-tf-primary`, `text-tf-text-primary`, `border-tf-border`, and `bg-tf-surface-2`. In a brand-neutral implementation, retain the same values but prefer semantic names such as `--color-primary`, `--color-surface`, and `--color-text-muted`. Keep a compatibility alias only when porting existing classes.

Existing soft/status values include `--tf-success-soft`, `--tf-warning-soft`, `--tf-danger-soft`, and `--tf-info-soft`. Existing card surface values include:

| Source token | Light value | Dark value |
|---|---|---|
| `--tf-card-blue` | `#eff6ff` | `rgba(96, 165, 250, 0.08)` |
| `--tf-card-teal` | `#eef7f0` | `rgba(98, 180, 109, 0.08)` |
| `--tf-card-amber` | `#fff8e8` | `rgba(214, 176, 74, 0.08)` |
| `--tf-card-violet` | `#f5f3ff` | `rgba(167, 139, 250, 0.08)` |
| `--tf-card-slate` | `#f8fafc` | `rgba(148, 163, 184, 0.06)` |
| `--tf-card-coral` | `#fff1f2` | `rgba(248, 113, 113, 0.08)` |

### Shadcn semantic variables

The source also defines `--background`, `--foreground`, `--card`, `--card-foreground`, `--popover`, `--popover-foreground`, `--primary`, `--primary-foreground`, `--secondary`, `--secondary-foreground`, `--muted`, `--muted-foreground`, `--accent`, `--accent-foreground`, `--destructive`, `--border`, `--input`, `--ring`, chart variables, and sidebar semantic variables. These use OKLCH values in light mode and are replaced under `.dark`. Preserve this semantic layer when using shadcn components.

## 10. Spacing System

The explicit custom spacing scale is:

| Token | Value | Typical role |
|---|---:|---|
| `--space-1` | 4px | Small separation |
| `--space-2` | 8px | Compact control gap |
| `--space-3` | 12px | Navigation/control gap |
| `--space-4` | 16px | Standard padding |
| `--space-5` | 20px | Small card spacing |
| `--space-6` | 24px | Page padding, major gaps, card spacing |
| `--space-8` | 32px | Larger internal separation |
| `--space-10` | 40px | Large composition gap |
| `--space-12` | 48px | Auth/display spacing |
| `--space-16` | 64px | Large spacing |

### Applied spacing rules

| Area | Existing values |
|---|---|
| Main page padding | `p-6` = `24px` |
| Major section gap | `gap-6` / `space-y-6` = `24px` |
| Page header padding | `p-6` = `24px` |
| Card default spacing | Card internal spacing token maps to Tailwind spacing `8`; small Card maps to `5` |
| Form field spacing | `space-y-2` = `8px` |
| Form section spacing | `space-y-8` = `32px` |
| Form grid gap | `gap-4` = `16px`, sometimes `gap-6` = `24px` |
| Drawer header/footer | `px-6 py-4` = `24px` horizontal, `16px` vertical |
| Drawer body | `px-6 py-6` = `24px` |
| Table header/cells | `px-4`; cells also `py-2` |
| Table toolbar | `space-y-4` = `16px` |
| Sidebar nav | `py-4`, `px-3` |
| Sidebar item | `px-3 py-2.5` |
| Header | `px-4`, `sm:px-6` |
| Empty state | `p-12` = `48px` |
| Notification rows | `px-4 py-3` = `16px` / `12px` |

Do not replace `p-6`/`gap-6` major rhythm with arbitrary large whitespace. The interface is dense and task-oriented.

## 11. Border System

| Border role | Existing value/treatment |
|---|---|
| Default width | `1px` through Tailwind border utilities |
| Default color | `--tf-border`: light `#dde5dc`; dark translucent white `0.08` |
| Strong color | `--tf-border-strong`: light `#c7d2c5`; dark translucent white `0.15` |
| Card/page surfaces | Explicit `border-tf-border` is common; base Card also has a foreground ring |
| Input border | `border-tf-border` |
| Table border | `border-tf-border` container and primitive dividers |
| Sidebar border | Right border `border-tf-border` |
| Header border | Bottom border `border-tf-border` |
| Drawer border | Left border and header/footer dividers |
| Modal ring | `ring-1 ring-foreground/10` |
| Card ring | `ring-1 ring-foreground/5` |
| Active navigation | `3px` left accent border |
| Error control | Danger border plus danger focus ring |
| Empty state | Dashed strong border |

Borders are the primary structural separator. Shadows add elevation but do not replace borders on most persistent surfaces.

## 12. Border Radius System

Declared tokens:

| Token | Value | Common role |
|---|---:|---|
| `--radius-sm` | 6px | Small controls |
| `--radius-md` | 10px | Standard control-level rounding |
| `--radius-lg` | 14px | Larger surfaces |
| `--radius-xl` | 20px | Extra-large surfaces |
| `--radius-full` | 9999px | Pills, badges, avatars, circular controls |

Observed class usage is not completely normalized to those token names:

- base Card: `rounded-lg`;
- inputs: `rounded-lg`;
- navigation items: `rounded-lg`;
- route-level header/table surfaces: `rounded-xl`;
- status badges: `rounded-[var(--radius-full)]`;
- avatar/back controls: `rounded-full`;
- default Dialog: `rounded-none`;
- alternate centered authentication panel: `rounded-2xl`.

The exact compiled pixel values of default Tailwind `rounded-lg`, `rounded-xl`, and `rounded-2xl` are not redefined in the inspected source. Use the explicit custom token values where the system calls for token-level fidelity and retain the class-level variations where matching an existing component.

## 13. Shadow and Elevation System

| Token | Existing value |
|---|---|
| `--shadow-xs` | `0 1px 2px rgba(0, 0, 0, 0.04)` |
| `--shadow-sm` | `0 2px 4px rgba(0, 0, 0, 0.06), 0 1px 2px rgba(0, 0, 0, 0.04)` |
| `--shadow-md` | `0 4px 8px rgba(0, 0, 0, 0.08), 0 2px 4px rgba(0, 0, 0, 0.04)` |
| `--shadow-lg` | `0 8px 24px rgba(0, 0, 0, 0.1), 0 2px 8px rgba(0, 0, 0, 0.06)` |
| `--shadow-xl` | `0 20px 40px rgba(0, 0, 0, 0.12), 0 4px 12px rgba(0, 0, 0, 0.06)` |

Observed mapping:

| Surface | Shadow |
|---|---|
| Page header bands | `shadow-sm` |
| Cards | `shadow-sm` or base Card shadow |
| Dropdown/notification panel | `shadow-xl` |
| Dialog | `shadow-md` |
| Drawer | `shadow-md` |
| Alternate auth panel | `shadow-[var(--shadow-xl)]` |
| Hover state | Usually background/color transition, not elevation change |

## 14. Icon System

The icon library is Lucide. Icons are primarily outlined and are paired with labels for actions.

| Context | Existing size |
|---|---:|
| Sidebar icon | `20px` (`h-5 w-5`) |
| Header icon | `20px` (`h-5 w-5`) |
| Standard action icon | Usually `16px`; primitive default is `14px` |
| Notification icon | `16px` |
| Detail icon | Usually `16px` or `20px` |
| Close icon | Lucide `XIcon`/`X` |
| Empty state icon | `32px` inside a `64px` circle |
| Avatar fallback | Initials, no icon required |

Icon-only controls use `IconButton` or shadcn Button icon sizes and should carry `aria-label` and, where present in the source, a title. Collapsed navigation uses tooltips. Icons normally precede text with a `gap-2` or explicit margin. Validation messages in the shared field component currently use a small inline SVG rather than Lucide; preserve this as a known exception if matching the source precisely.

## 15. Button System

Primary implementation: `components/ui/button.tsx`.

### Shared base

The base class includes `rounded-md`, `text-xs`, `font-semibold`, `tracking-widest`, uppercase text, transparent border, `transition-all`, visible focus styling, an active one-pixel downward translation, disabled pointer suppression, disabled opacity, and icon sizing rules.

### Variants

| Variant | Existing behavior |
|---|---|
| Primary/default | Semantic primary background/foreground; hover `bg-primary/80` |
| Outline | Border and transparent background; muted hover; expanded state uses muted background |
| Secondary | Semantic secondary background/foreground; subtle mixed-color hover |
| Ghost | Transparent until muted hover; expanded state uses muted background |
| Destructive | Translucent danger background and danger text; stronger danger focus ring |
| Link | Primary text with underline and underline offset |

### Sizes

| Size | Height | Horizontal padding | Gap |
|---|---:|---:|---:|
| Default | `40px` (`h-10`) | `24px` (`px-6`) | `6px` (`gap-1.5`) |
| `xs` | `28px` (`h-7`) | `12px` (`px-3`) | `4px` (`gap-1`) |
| `sm` | `36px` (`h-9`) | `16px` (`px-4`) | `4px` (`gap-1`) |
| `lg` | `44px` (`h-11`) | `32px` (`px-8`) | `6px` (`gap-1.5`) |
| `icon` | `40px` (`size-10`) | fixed | n/a |
| `icon-xs` | `28px` (`size-7`) | fixed | n/a |
| `icon-sm` | `36px` (`size-9`) | fixed | n/a |
| `icon-lg` | `44px` (`size-11`) | fixed | n/a |

### State rules

- Primary workflow actions commonly add `bg-tf-primary text-white hover:bg-tf-primary-hover`.
- Route-level workflow buttons often override uppercase text with `normal-case tracking-normal`.
- Focus uses a visible `2px` ring with ring opacity from the semantic ring token.
- Disabled controls use `pointer-events-none opacity-50`.
- Loading controls remain disabled and show a `16px` border spinner with text such as `Saving...`.
- Destructive actions are visually distinct and require confirmation when they remove a record.
- Icon-only buttons remain stable in `size-7`, `size-9`, `size-10`, or `size-11` boxes.

## 16. Form and Input System

Primary references:

- `components/ui/form.tsx`
- `components/ui/input.tsx`
- `components/ui/textarea.tsx`
- `components/forms/FormField.tsx`
- `components/forms/DrawerForm.tsx`

### Form architecture

Use React Hook Form with a Zod resolver. The shared Form components connect labels, controls, descriptions, errors, `aria-describedby`, and `aria-invalid`. Feature/page modules own the schema and mutation, while shared field components own visual treatment.

### Field dimensions and styling

| Control | Existing specification |
|---|---|
| Input height | `40px` (`h-10`) |
| Input radius | `rounded-lg` |
| Input background | Surface token |
| Input border | `border-tf-border` |
| Input shadow | `shadow-sm` in shared FormField composition |
| Input focus | `focus-visible:ring-2`, green primary ring, no offset |
| Textarea minimum height | `100px` (`min-h-[100px]`) |
| Textarea resize | `resize-y` |
| Label | Above control, `text-sm font-medium`, secondary text |
| Required marker | Danger-colored `*`, `ml-0.5` |
| Field gap | `space-y-2` = `8px` |
| Helper text | `text-xs`, muted text |
| Error text | `text-sm font-medium`, danger text, `mt-1.5`, inline icon |
| Error control | Danger border and `ring-1` danger ring |
| Error focus | First invalid field may be auto-focused when body is active |

### Controls

| Control | Existing pattern |
|---|---|
| Text/email/password/number/tel/url/date/datetime/color | Input `type` is passed through shared FormField |
| Textarea | Shared controlled textarea, min `100px`, vertical resize |
| Select | Full-width `FilterSelect` trigger; error wrapper adds danger border/ring |
| Combobox | Popover + Command; trigger is a full-width outline Button; content `w-[300px] p-0`; list max `300px` |
| Search | Command/Input composition; toolbar search width `250px`, expands to `350px` at large screens |
| Date range | Shared `DateRangePicker` |
| Checkbox/radio | shadcn primitives are available |
| Switch | shadcn Switch, used for binary settings/choices |
| File upload | No universal shared file-upload control was established; implement as a feature composite only when required |

### Form layout

Default form grids are one column below `md` and two columns at `md` and above. Feature sections commonly use `space-y-4`; the overall form commonly uses `space-y-8`. Full-width fields can span columns with `md:col-span-2`.

The standalone authentication form is a known variation: its controls are `h-11`, use leading icons, and use a full-width `h-11` submit button. Do not silently apply that height to all application forms.

## 17. Card and Panel System

Primary reference: `components/ui/card.tsx`.

### Base Card

| Property | Existing value |
|---|---|
| Layout | `flex flex-col` |
| Internal spacing | `--card-spacing` mapped to Tailwind spacing `8`; small size maps to `5` |
| Overflow | `overflow-hidden` |
| Radius | `rounded-lg` |
| Background | Semantic card background |
| Text | `text-sm` semantic card foreground |
| Shadow | `shadow-sm` |
| Ring | `ring-1 ring-foreground/5` |

`CardHeader`, `CardContent`, and `CardFooter` use the card spacing for horizontal padding. Header gap is `1.5` spacing, and an explicit bottom border receives bottom padding. `CardTitle` is heading-font, `text-lg`, semibold, uppercase, and `tracking-wider`. `CardAction` occupies the second grid column and aligns to the top/right. `CardFooter` is a flex row and adds top padding when it has a top border.

### Route-level panel

Many pages use raw divs rather than Card for page bands and table surfaces:

```text
bg-tf-surface p-6 rounded-xl border border-tf-border shadow-sm
```

Use this as the route-level panel pattern. It is not the same as the base Card primitive and should remain a documented variation.

### Hover behavior

Persistent panels generally do not gain a hover shadow. Interactive rows/panels change background color with a transition. Do not introduce decorative elevation or glass effects.

## 18. Metric / KPI Card System

Primary references: `components/dashboard/KpiRow.tsx` and `components/shared/LoadingSkeleton.tsx`.

The metric card is a reusable presentation for a label, primary value, supporting information, and optional trend or icon. It must not assume what the metric represents.

### Skeleton-established geometry

| Property | Existing value |
|---|---|
| Height | `140px` |
| Width | `w-full` within its grid |
| Padding | `p-5` = `20px` |
| Radius | `rounded-xl` utility |
| Border | `1px` `border-tf-border` |
| Background | `bg-tf-surface` |
| Shadow | `shadow-sm` |
| Icon placeholder | `40px` circular |
| Value placeholder | `32px` high skeleton; runtime values use 36px or 28px utility |

### Recommended composition based on the existing implementation

```text
Metric Card
├── Label + icon/trend row
├── Primary metric value
└── Supporting text and change indicator
```

The containing grid determines the number of columns. A universal runtime metric-card width, exact icon container color, and exact trend semantics could not be determined from the inspected shared skeleton alone. Preserve the `140px` loading geometry and metric typography.

## 19. Data Table System

Primary references:

- `components/tables/DataTable.tsx`
- `components/tables/DataTableToolbar.tsx`
- `components/tables/DataTablePagination.tsx`
- `components/tables/DataTableRowActions.tsx`
- `components/tables/DataTableColumnHeader.tsx`
- `components/ui/table.tsx`

### Table structure

```text
DataTable
├── Toolbar
│   ├── Search
│   ├── Filters
│   ├── Date controls
│   ├── Column visibility
│   └── Optional export/bulk actions
├── Bordered table surface
│   ├── Header
│   └── Body rows
└── Pagination
```

### Dimensions and states

| Property | Existing value |
|---|---|
| Outer surface | `rounded-md border border-tf-border bg-tf-surface overflow-hidden` |
| Header background | `bg-tf-surface-2` |
| Header height | `40px` (`h-10`) |
| Header padding | `px-4` = `16px` |
| Header typography | `text-xs uppercase tracking-wider`, muted, semibold |
| Row height | `52px` (`h-[52px]`) |
| Cell padding | `px-4 py-2` = `16px` / `8px` |
| Cell typography | `text-sm`, primary text |
| Alternating row | Odd row `bg-tf-surface-2/50`; even row transparent |
| Hover | `bg-tf-primary-soft transition-colors` |
| Loading rows | Five skeleton rows |
| Skeleton cell | `h-4 w-full` |
| Empty row | `h-24`, centered; injected empty component or `No results found.` |
| Pagination page sizes | `10, 20, 30, 40, 50` |
| Horizontal behavior | Preserve table width and allow horizontal scrolling |

TanStack Table state includes sorting, column filters, column visibility, row selection, global filtering, and pagination. Row actions are a three-dot dropdown with view/edit/delete actions. Destructive deletion opens an AlertDialog and explicitly communicates permanence. Optional export uses visible filtered columns and excludes the actions column.

### Table content conventions

Generic records may use a mono-styled identifier/reference column, two-line identity/detail cells, muted secondary values, status badges, and a final actions column. These are content patterns, not domain-specific entities.

## 20. Modal / Dialog System

Primary reference: `components/ui/dialog.tsx`.

### Dialog structure

```text
Dialog
├── Overlay
└── Content
    ├── Header
    │   └── Title and description
    ├── Body
    └── Footer
        └── Actions
```

### Dimensions and behavior

| Property | Existing value |
|---|---|
| Overlay position | `fixed inset-0` |
| Overlay layer | `z-50` |
| Overlay color | `bg-black/20` |
| Overlay blur | Optional `backdrop-blur-sm` when supported |
| Overlay transition | `duration-100`, fade in/out |
| Content position | Centered at `top-1/2 left-1/2` |
| Content transform | `-translate-x-1/2 -translate-y-1/2` |
| Content width | `w-full max-w-[calc(100%-2rem)]` |
| Small-screen max width | `sm:max-w-md` |
| Content gap | `gap-6` |
| Content padding | `p-6` = `24px` |
| Background | Semantic popover/surface |
| Radius | `rounded-none` by default |
| Shadow | `shadow-md` |
| Ring | `ring-1 ring-foreground/10` |
| Animation | 100ms fade and zoom from 95% |
| Close control | Absolute `top-5 right-5`, `size-9`, ghost, secondary background |

`DialogHeader` is a vertical flex block with `gap-2`. `DialogTitle` is heading-font, `text-lg`, semibold, uppercase, with tracking. `DialogFooter` is column-reverse on narrow screens and a right-justified row at `sm` with `gap-2`.

The source does not define a universal maximum height or a separate large/full-screen modal primitive. Scroll behavior beyond the default Radix/content behavior could not be determined. Focus trapping, Escape handling, focus return, and screen-reader semantics come from Radix; no custom behavior was added in the wrapper.

Use AlertDialog for destructive confirmations. Use Dialog for standard confirmations, alerts, and compact forms. Use DrawerForm for the primary create/edit workflow.

## 21. Drawer / Side Panel System

Primary references:

- `components/ui/sheet.tsx`
- `components/forms/DrawerForm.tsx`
- `hooks/use-entity-drawer.ts`
- `store/create-drawer.store.ts`

### Canonical structure

```text
Sheet
├── Overlay
└── Right-side Drawer Content
    ├── Header
    │   ├── Title
    │   └── Description
    ├── Scrollable Body
    │   └── Form sections and fields
    └── Footer
        ├── Cancel
        └── Submit/Create/Save
```

### Dimensions and styling

| Property | Existing value |
|---|---|
| Default side | Right |
| Generic Sheet width | `w-3/4` |
| Generic small-screen max width | `sm:max-w-sm` |
| Small DrawerForm | `sm:!max-w-[400px]` |
| Medium DrawerForm | `sm:!max-w-[560px]` |
| Large DrawerForm | `sm:!max-w-[720px]` |
| Extra-large DrawerForm | `sm:!max-w-[900px]` |
| Height | Full viewport, `inset-y-0 h-full` |
| Overlay | `fixed inset-0 z-50 bg-black/20` |
| Overlay animation | Fade in/out, optional backdrop blur |
| Content layout | `flex flex-col` |
| Content padding | `p-0` |
| Content background | Surface/popover; DrawerForm overrides to `bg-tf-surface` |
| Content border | Left border using the border token |
| Header | `px-6 py-4`, bottom border, surface background, text-left |
| Header title | `text-xl font-semibold` |
| Header description | `text-sm`, secondary text |
| Body | `flex-1 overflow-y-auto px-6 py-6` |
| Body form gap | `space-y-6` |
| Footer | `px-6 py-4`, top border, surface background |
| Footer layout | Right aligned, `gap-3` |
| Footer order | Outline Cancel followed by primary submit |
| Animation | Right slide/fade, `duration-200 ease-in-out`, slide distance 10 |
| Layer | `z-50` |

The header and footer do not scroll because the content is a flex column and only the body has `overflow-y-auto`. This is the source's sticky-equivalent behavior.

### Form and mutation behavior

The form body is assigned `id="drawer-form"`; the footer submit targets it with `form="drawer-form"`. Submit disables the footer actions and renders a white `16px` spinner with `Saving...` or an equivalent label. A successful mutation shows a success toast, closes the drawer, and resets form defaults. A failed mutation leaves the drawer open and preserves input values while showing a parsed error toast.

The wrapper tracks whether a Select or Popover is mounted during pointer capture and prevents the Drawer outside-interaction handler from closing the form when the user is interacting with that control. Preserve this behavior when using Radix overlays inside the drawer.

Radix supplies focus trapping and Escape close behavior. A distinct custom mobile full-screen drawer mode was not found; narrow screens use the generic `w-3/4` behavior while the `sm` max-width variants apply above that breakpoint.

## 22. Dropdown, Popover, and Command System

Most dropdowns and popovers use shadcn/Radix primitives. The notification surface is a known custom exception.

| Pattern | Existing dimensions/behavior |
|---|---|
| User menu | `w-56`, aligned end, surface/border, labels and separators |
| Row-action menu | Three-dot trigger with view/edit/delete items |
| Combobox | Popover `w-[300px] p-0`, aligned start, searchable Command list |
| Combobox list | `max-h-[300px] overflow-y-auto` |
| Collapsed-nav tooltip | Right side, `sideOffset=15`, `100ms` delay |
| Notification panel | `w-80`, `rounded-xl`, border, surface, `shadow-xl`, `z-50` |
| Notification list | `max-h-[360px]`, vertical scrolling, divided rows |

Notification rows use `px-4 py-3`, type-colored circular `32px` icon containers, a small unread dot, truncated title/body, a `10px` timestamp, and a hover surface. The custom panel has a fixed `z-40` backdrop and a `z-50` panel. It fetches at most 20 items and polls every `30_000ms`.

Radix provides keyboard behavior, positioning, focus handling, and animation for its controls. The hand-built notification panel uses click-outside closure but no custom keyboard behavior was established.

## 23. Tabs System

Primary reference: `components/ui/tabs.tsx`, with route-level usage in detail and settings views.

The base Tabs primitive uses compact uppercase triggers with `tracking-wider`. Detail pages commonly override the list to:

```text
bg-tf-surface border border-tf-border p-1 rounded-lg
```

Active detail triggers use the primary background and white text. Settings uses a wrapped full-width list on narrow screens, with `flex-1 sm:flex-none`, `py-2.5 px-4`, `rounded-md`, and category-specific soft active colors. The source includes primary-soft, violet, amber, and blue route-level active treatments. A universal tab height or underline indicator was not established; the existing canonical detail treatment is filled active tabs rather than an underline.

## 24. Badge and Status System

Primary reference: `components/shared/StatusBadge.tsx` and `constants/status.ts`.

```text
StatusBadge
└── Inline semantic pill
    └── Status label
```

| Property | Small | Medium |
|---|---:|---:|
| Horizontal padding | `8px` (`px-2`) | `10px` (`px-2.5`) |
| Vertical padding | `2px` (`py-0.5`) | `4px` (`py-1`) |
| Text | `10px` | `.tf-caption` = `12px` |
| Radius | `rounded-[var(--radius-full)]` = `9999px` |
| Weight | `font-medium` |
| Alignment | `inline-flex items-center justify-center` |
| Wrapping | `whitespace-nowrap` |

The status map supplies semantic background/text pairs for success, warning, danger, info, and neutral states. Unknown values fall back to surface-2 background and secondary text. The badge formatter normalizes underscore/space/hyphen-separated values into title case. Badges do not add icons by default.

Generic semantic states to preserve are:

| State | Color family |
|---|---|
| Success/positive | Success and success-soft |
| Warning/attention | Warning and warning-soft |
| Error/destructive | Danger and danger-soft |
| Informational | Info and info-soft |
| Neutral/default | Surface-2 and secondary text |
| Selected/active | Primary-soft and primary |

## 25. Empty States

Primary reference: `components/shared/EmptyState.tsx`.

```text
Empty State
├── Centered dashed surface
│   ├── 64px circular icon container
│   ├── Heading
│   ├── Description
│   └── Optional primary action
```

| Property | Existing value |
|---|---|
| Alignment | Centered, text centered |
| Container padding | `p-12` = `48px` |
| Container radius | `rounded-xl` |
| Border | Dashed strong border |
| Background | `bg-tf-surface-2` |
| Icon container | `h-16 w-16` = `64px` |
| Icon container radius | `rounded-full` |
| Icon size | `h-8 w-8` = `32px` |
| Icon container background | `bg-tf-surface` |
| Icon color | Muted text |
| Icon container shadow | `shadow-sm` |
| Heading | `.tf-h3`, primary text, `mb-2` |
| Description | `.tf-body`, secondary text, `max-w-md`, `mb-6` |
| Action | Primary button, normal-case/tracking-normal |

The table component accepts an injected empty state. A simple control-specific empty state may omit the icon, but the canonical reusable empty presentation is the dashed centered surface above.

## 26. Loading System

Loading is component-scoped and preserves layout geometry.

| Loading context | Existing behavior |
|---|---|
| Page/detail fetch | `PageSkeleton` is used while data is unavailable |
| Metric cards | `KpiCardSkeleton`, fixed `140px` height |
| Table | Five skeleton rows; cells use `h-4 w-full` |
| Generic table | `DataTableSkeleton`, configurable rows/columns |
| Chart/panel | `ChartSkeleton`, default height `280px` |
| Auth/shell | Centered `8px` border spinner with transparent top |
| Submit action | Disabled button, `16px` inline spinner, loading text |
| Background refresh | Existing content remains but receives `opacity-50 pointer-events-none` |
| Skeleton motion | `animate-pulse` |
| Spinner motion | `animate-spin` |

Avoid replacing an entire populated page during background refresh. Preserve the existing information and show the dimmed/non-interactive state.

## 27. Error System

The source uses layered error handling:

1. `ErrorBoundary` isolates render failures for the application shell and individual dashboard widgets.
2. `ErrorState` provides a recoverable request error with retry.
3. The authenticated layout provides a full-screen connection failure state with an error icon, explanatory message, retry action, and a small set of generic quick links.
4. Form validation errors render inline beside their fields.
5. Mutation failures use parsed error toasts while preserving the current form.

The full-screen failure state uses an `80px` circular danger-soft icon area, a large heading, explanatory text, a full-width `h-12` retry button, and a two-column quick-link grid. A universal error-page max-width beyond the observed `max-w-md` content wrapper was not established.

## 28. Toast and Notification System

Primary references:

- `components/ui/sonner.tsx`
- `lib/toast-utils.ts`
- `lib/error-parser.ts`
- `app/layout.tsx`

### Toast configuration

| Property | Existing value |
|---|---|
| Library | Sonner |
| Position | `top-right` |
| Rich colors | Enabled with `richColors` |
| Icons | Lucide icons for success/info/warning/error/loading |
| Theme | Theme-aware semantic colors |
| Deduplication | ID defaults to message or parsed error code |
| Width | Not explicitly customized in source |
| Duration | Not explicitly customized in source |
| Animation | Delegated to Sonner/default configuration; custom project value could not be determined |

Use `showSuccess`, `showError`, `showInfo`, and `showWarning`. Error helpers parse technical errors into user-facing titles/descriptions and log technical details separately. Success descriptions may contain a generated record reference, but the helper itself is domain-neutral.

Do not place business logic directly around Sonner in individual pages when the centralized helper can express the state.

## 29. Responsive System

The source uses Tailwind responsive prefixes `sm`, `md`, `lg`, and `xl`. No custom breakpoint values were found in the inspected source, so numeric breakpoint values should be taken from the target Tailwind configuration rather than invented here.

| Prefix | Existing behavior |
|---|---|
| Base/below `sm` | Header/action rows stack; breadcrumbs are hidden; controls wrap; dialog content is viewport-constrained; tables remain wide and scroll |
| `sm` | Page headers become row layouts; breadcrumbs appear; drawer max-width variants apply; auth content aligns for larger screens |
| `md` | Form grids become two columns; detail metadata expands; settings controls adjust |
| `lg` | Dashboard grids become 3/2 columns; split authentication view appears; mobile menu button disappears; shell is desktop-oriented |
| `xl` | Some metric grids reach four columns; toolbar/search receives larger width |

### Responsive component rules

- Sidebar: fixed expanded/collapsed shell; topbar menu toggles it below `lg`; no separate mobile overlay was implemented.
- Header: `px-4` becomes `px-6`; breadcrumbs appear at `sm`; mobile menu hides at `lg`.
- Page headers: column layout becomes row at `sm`.
- Forms: one column below `md`, two columns at `md`.
- Dashboard/detail grids: one column below `lg`, multi-column at `lg`.
- Tables: keep semantic table layout and allow horizontal scrolling.
- Drawers: generic width is `w-3/4` on narrow screens; fixed max widths apply at `sm`.
- Dialogs: width is `max-w-[calc(100%-2rem)]`, then `sm:max-w-md`.
- Buttons: retain intrinsic dimensions; action groups wrap rather than shrink unpredictably.

## 30. Animation and Motion System

Declared motion tokens:

| Token | Value |
|---|---|
| `--duration-fast` | `150ms` |
| `--duration-base` | `200ms` |
| `--duration-slow` | `300ms` |
| `--duration-slower` | `500ms` |
| `--ease-default` | `cubic-bezier(0.4, 0, 0.2, 1)` |
| `--ease-spring` | `cubic-bezier(0.34, 1.56, 0.64, 1)` |
| `--ease-out` | `cubic-bezier(0, 0, 0.2, 1)` |

Observed component motion:

| Component/state | Existing motion |
|---|---|
| Sidebar width/shell offset | `300ms ease-out` |
| Sidebar item | `200ms ease-out` |
| Dialog | `100ms` fade and zoom in/out |
| Drawer | `200ms ease-in-out`, fade and slide by 10 |
| Expandable context area | `animate-in slide-in-from-top-2 duration-200` |
| Skeleton | `animate-pulse` |
| Spinner | `animate-spin` |
| Hover controls | Background/color transitions, generally `150-200ms` |

The spring token is declared but was not observed on an inspected component. No universal page-enter animation was established. Do not add broad entrance animations or decorative motion by default.

## 31. Z-Index and Layering

| Layer | Existing value |
|---|---:|
| Normal content | auto |
| Sticky topbar | `z-30` |
| Fixed sidebar | `z-40` |
| Notification backdrop | `z-40` |
| Dialog overlay | `z-50` |
| Dialog content | `z-50` |
| Drawer overlay | `z-50` |
| Drawer content | `z-50` |
| Notification panel | `z-50` |
| Tooltip | Radix-managed; no custom project value established |
| Toast | Sonner-managed; no custom project value established |

There is no centralized z-index token map. Preserve the numeric hierarchy above when recreating the shell.

## 32. Interaction State System

### Default

Use a surface background, token border, primary/secondary text, and the component's normal density. Avoid empty decorative space or unbounded rounded containers.

### Hover

Use muted surface or primary-soft background, text/icon color changes, and a short transition. Tables use `bg-tf-primary-soft`; sidebar items use `bg-tf-surface-2`; many buttons use a darker/lighter token variant.

### Focus

Use visible focus rings. Buttons use a `2px` ring from the semantic ring token. Inputs use a `2px` green primary ring without offset. Error controls replace the normal focus ring with danger.

### Active/selected

Use primary-soft or primary background, active text, and where relevant a `3px` left border. Tabs use filled active backgrounds in the canonical detail treatment. Selected table rows use TanStack `data-state`; the source defines row selection state but the main row class emphasizes hover/striping.

### Disabled

Use `disabled:pointer-events-none disabled:opacity-50` for shadcn Buttons and disabled controls in forms. Do not change layout dimensions when disabled.

### Loading

Disable the relevant action, preserve its dimensions, and add a small spinner plus concise loading text. Preserve existing page content during background refresh and dim it with pointer events disabled.

### Error

Use danger border/ring for fields, inline danger message with icon, parsed error toast for mutation/request failures, and a retry action for recoverable page errors.

### Success

Use success semantic color/soft surface, a success toast, and update/close/reset the relevant workflow after a successful mutation.

## 33. Create, Edit, View, and Delete Workflow

The domain-neutral CRUD lifecycle is:

```text
List
├── Create → open DrawerForm → validate → mutate → success toast → close/reset
├── Edit → map record to form → open DrawerForm → validate → mutate → success toast → close/reset
├── View → navigate to detail route
└── Delete → open AlertDialog → confirm → mutate → success/error toast
```

### Create/edit rules

- `useEntityDrawer` owns open/close state, edit identifier, and create/edit mode.
- Create resets to feature defaults.
- Edit maps an existing record to form values.
- The page supplies a Zod schema and mutation hook.
- Permission checks determine whether create/edit controls are rendered.
- Success feedback is affirmative and may include a generated reference in the description.
- Mutation failures preserve the drawer and user input.
- The drawer footer owns Cancel and submit controls.

### View/detail rules

- View action navigates with `router.push('/entity/id')` in the source pattern; substitute the new application's entity route.
- Detail data shows `PageSkeleton` while loading.
- `DetailHeader` owns the back action, title, context, and action slot.
- Cards, tabs, related panels, and feature drawers are composed below the header.

### Delete rules

- Delete is permission-gated.
- Delete is exposed through row actions.
- Confirmation uses AlertDialog.
- Copy states that the action is permanent/cannot be undone.
- Success removes or refreshes the row and shows a success toast.
- Failure shows a parsed error toast.

## 34. Component Architecture and Reuse Rules

| Category | Responsibility | Existing pattern |
|---|---|---|
| Global UI primitive | Accessible low-level control | `components/ui/Button`, `Input`, `Dialog`, `Sheet`, `Tabs`, `Table` |
| Shared UI component | Repeated domain-neutral presentation | `EmptyState`, `ErrorState`, `PageSkeleton`, `DetailHeader`, `StatusBadge` |
| Layout component | Shell/navigation concerns | `Sidebar`, `Topbar`, `SidebarNav`, `UserMenu`, notifications |
| Composite workflow | Repeated multi-control workflow | `DrawerForm`, `FormField`, `DataTable`, toolbar, row actions |
| Feature component | Business/data-specific behavior | Feature panels and record-specific drawers |
| Page-specific component | One route's data orchestration/composition | Column definitions, form sections, page action wiring |
| Utility | Non-visual logic/infrastructure | `lib`, `hooks`, `store`, `constants`, `types` |

### Placement rules

- Put accessible primitives in `components/ui` and compose them; do not recreate Button/Input/Dialog/Table equivalents.
- Put a repeated domain-neutral visual state in `components/shared`.
- Put shell behavior in `components/layout`.
- Put a workflow used by multiple record types in `components/forms` or `components/tables`.
- Put schema, query, mutation, and mapping logic under the relevant `features/<entity>` folder.
- Keep route-level permission, column, and mutation orchestration in the page unless it is truly shared.
- Use PascalCase component names and filenames.
- Use lowercase plural route directories and `[id]` for detail routes.
- Use `use-*.ts` for hooks, `*.store.ts` for Zustand stores, and `*.schema.ts` for schemas.
- Use `@/` aliases consistently.

## 35. Data, State, and Communication

### Server/query state

TanStack Query is configured through `lib/query-client.ts` and `providers/QueryProvider.tsx`. The source uses a default stale time of `30s`, garbage collection of `10m`, no retry for `400`, `401`, `403`, `404`, and `422`, one retry for network/`429`/server errors, no mutation retries, and disabled refetch-on-window-focus. Query persistence uses IndexedDB through `idb-keyval`, with a maximum age of seven days, and persists only `shared` and `dashboard` top-level query keys.

### Client state

Use Zustand for shell and transient UI state:

- persisted sidebar open/collapsed state;
- persisted authentication user state;
- active context/tenant selection where a future application needs it;
- create-drawer request state;
- invalidation timestamps or similar cross-component signals.

### Component communication

- Parent pages pass data and event handlers to shared composites.
- Form components receive RHF `control`, field name, labels, options, and state.
- Table pages pass column definitions, row data, filters, loading, empty content, and toolbar content.
- Drawer open/edit identity is shared through `useEntityDrawer` or a create-drawer store.
- Query invalidation and mutation success update shared list/detail state.
- Toast helpers provide user feedback without coupling shared components to domain copy.

## 36. Visual Density and Design Principles

### Density assessment

The system is compact-to-comfortable and operational rather than spacious or editorial.

- Tables use fixed `52px` rows and compact `40px` headers.
- Forms use `8px` field gaps and `16px`/`24px` grid gaps.
- Pages use `24px` major gaps, not oversized section spacing.
- Navigation uses `10px` vertical item padding with `20px` icons.
- Cards use moderate internal padding and compact headings.
- Information is presented in dense grids, two-line table cells, muted labels, and short action controls.
- Decoration is restrained: borders, soft surfaces, modest shadows, and semantic color accents carry hierarchy.

### Supported design principles

- Consistency over novelty: shared primitives and recurring page templates dominate.
- Operational clarity: titles, context, filters, data, and actions are visibly separated.
- Strong information hierarchy: heading font, muted labels, primary values, and mono identifiers have distinct roles.
- Controlled spacing: `p-6`, `gap-6`, `gap-4`, and `space-y-6` recur across pages.
- Predictable interactions: list actions, drawers, confirmations, toasts, and retry states follow repeated patterns.
- Semantic state feedback: success, warning, danger, info, selected, loading, and empty states use distinct token families.
- Reuse through composition: pages compose shadcn primitives and shared composites.
- Restrained visual treatment: no universal glassmorphism, decorative gradients, excessive shadows, or page-enter animations are present in the application shell.

## 37. Known Variations and Inconsistencies

These variations exist in the source and should not be silently normalized when seeking visual fidelity.

| Component/pattern | Actual variation | Location/pattern | Canonical or optional? |
|---|---|---|---|
| Card radius | Base Card `rounded-lg`; route surfaces commonly `rounded-xl` | Card primitive versus page header/table bands | Both; use by component family |
| Dialog radius | Default Dialog `rounded-none`; centered auth panel `rounded-2xl` | Dialog primitive versus alternate auth route | Dialog default is canonical; auth is optional variation |
| Button casing | Primitive uppercase/tracked; many workflow controls normal case | Button primitive versus route-level overrides | Primitive default canonical; override for readable workflow labels |
| Input height | Shared forms `h-10`; auth controls `h-11` | FormField/Input versus auth page | Application form canonical; auth variation |
| Card border | Base Card uses ring; routes often add explicit token border | Card primitive versus detail/list routes | Both are established |
| Form gaps | `gap-4`, `gap-6`, and `space-y-8` | Field grids, settings, form sections | Density varies by nesting level |
| Notification panel | Hand-built absolute panel, not DropdownMenu | Notification control | Optional specialized composite |
| Settings composition | Consolidated tabs and standalone subroutes | Settings routes | Two established route patterns |
| Data access | TanStack Query hooks and direct API/local state | List versus some detail implementations | Architecture is mixed; new work should choose one deliberately |
| Mobile navigation | Fixed sidebar toggled by topbar; no distinct mobile drawer | Shell | Existing behavior is canonical for fidelity |
| Typography application | Utility classes and raw Tailwind sizes coexist | `.tf-h2` alongside `text-3xl`, `text-sm` | Token utilities preferred for new reusable components; raw classes remain a source variation |
| Header token mapping | `--tf-header-bg` is used directly but not mapped in `@theme` | Topbar/global CSS | Source implementation detail |
| Status badge iconography | Badge has no default icon | StatusBadge | Canonical |
| Toast measurements | Position is explicit; width/duration are delegated | Sonner | Do not invent values |
| Breakpoint values | Prefixes are visible; custom numeric values are not | Tailwind usage | Do not claim unverified pixel breakpoints |

## 38. Canonical Component Index

| Component | Canonical pattern | Dimensions | Key styling | Behavior |
|---|---|---|---|---|
| Sidebar | Fixed shell navigation | `240px` / `64px`, full height | White/dark surface, right border, active green accent | Persisted collapse; role-filtered items; collapsed tooltips |
| Topbar | Sticky shell header | `60px` high | Surface, bottom border, `shadow-sm`, `px-4 sm:px-6` | Search, breadcrumbs, notifications, theme, focus, user menu |
| Button | shadcn Button variants | `h-7/9/10/11`, icon `28/36/40/44px` | Compact uppercase default; semantic variants | Focus ring, disabled opacity, active translate, loading state |
| Input | shadcn Input | `40px` high | `rounded-lg`, surface, token border, green ring | Controlled through RHF, error styling |
| Card | shadcn Card | Internal spacing `8` or `5` | `rounded-lg`, shadow, foreground ring | Header/content/footer/action slots |
| Page panel | Route-level surface band | Commonly `p-6` | `rounded-xl`, border, `shadow-sm` | Title/actions or table wrapper |
| Metric card | Dashboard metric composite | `140px` loading height, `p-5` | Surface, border, shadow, large metric type | Loading skeleton and responsive grid |
| DataTable | TanStack + shadcn Table | `40px` header, `52px` rows | Surface-2 header, striped rows, primary-soft hover | Sort/filter/search/select/paginate/export |
| Dialog | Radix-centered modal | `max-w-md`, `p-6` | Black/20 overlay, `z-50`, `rounded-none`, zoom/fade | Focus trap, Escape, close button, responsive footer |
| Drawer | Radix right Sheet | `400/560/720/900px` max variants | Surface, left border, fixed header/footer, scroll body | Create/edit form, popover outside-click protection |
| Tabs | shadcn Tabs | Route-defined; list commonly `p-1` | Filled primary active state | Details/settings view switching |
| Badge | Semantic pill | `10px`/`12px` text, full radius | Status-specific soft background/text | Normalizes status label; neutral fallback |
| Empty state | Centered dashed surface | `p-12`, `64px` icon container | Surface-2, strong dashed border | Optional primary action |
| Toast | Sonner wrapper | Position `top-right` | Rich semantic colors, Lucide icons | Deduplicated success/error/info/warning feedback |

## 39. Design Token Architecture for a New Application

### Foundation tokens

Keep these as the stable visual foundation:

```text
Colors: background, surface, surface-2, border, text, primary, accent, status
Typography: heading/body/mono families, weights, sizes, line heights
Spacing: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64px
Radius: 6, 10, 14, 20px, full
Shadows: xs, sm, md, lg, xl
Motion: 150, 200, 300, 500ms and declared easings
Shell: 240px, 64px, 60px
```

### Semantic tokens

Map foundation values into:

```text
background
surface
surface-secondary
foreground-primary
foreground-secondary
foreground-muted
foreground-inverse
border
border-strong
primary
primary-hover
primary-soft
accent
success
warning
danger
info
```

The primary brand color is replaceable; the component dimensions, typography, spacing, radius, shadow, and motion system should remain unchanged if a future application changes its brand color.

### Component tokens

Component classes should consume semantic tokens rather than hardcoded domain colors:

```text
Button: primary, primary-hover, foreground-inverse, focus-ring
Input: surface, border, primary focus, danger error
Card: surface, border/ring, shadow, radius
Navigation: sidebar background, sidebar text, active background/text/accent
Dialog: overlay, popover surface, ring, shadow, z-50
Drawer: overlay, surface, border, shadow, z-50
Table: surface, surface-2 header/stripe, primary-soft hover
Badge: success/warning/danger/info/neutral pairs
Toast: semantic status colors and icon mappings
```

## 40. New Application Implementation Sequence

1. Establish the App Router route groups and TypeScript alias.
2. Load IBM Plex Sans, Inter, Roboto, and JetBrains Mono with the exact weights.
3. Add global CSS variables for light/dark colors, spacing, radius, shadow, motion, scrollbar, sidebar, and topbar.
4. Configure Tailwind v4 and shadcn/Radix primitives.
5. Implement the root provider order: theme, auth/session, sidebar hydration, query, Sonner.
6. Implement the fixed 240px/64px sidebar and persisted collapse state.
7. Implement the sticky 60px topbar with breadcrumbs, command/search, notifications, theme, focus, and user menu.
8. Implement the authenticated shell with matching sidebar offsets and `main p-6 overflow-y-auto`.
9. Build the primitive layer: Button, Input, Label, Select, Popover, Command, Tabs, Badge, Card, Dialog, Sheet, Table, Tooltip.
10. Build shared states: EmptyState, ErrorState, PageSkeleton, StatusBadge, DetailHeader, and formatters.
11. Build RHF/Zod field composites and responsive form grids.
12. Build the four-width right-side DrawerForm with scroll body and footer.
13. Build DataTable, toolbar, row actions, AlertDialog deletion, skeleton rows, empty injection, and pagination.
14. Build toast/error helpers and mutation feedback conventions.
15. Build the dashboard metric and panel composition.
16. Build generic list pages with entity-specific columns, schemas, queries, mutations, and permissions.
17. Build generic detail pages with DetailHeader, cards, tabs, related data, and feature drawers.
18. Add settings and document/print templates as deliberate variants.
19. Validate narrow/base, `sm`, `md`, `lg`, and `xl` layouts with table overflow and drawer/dialog behavior.
20. Compare each new page against the canonical component index and known variations before adding any new pattern.

## 41. Reusability Rule

The application domain may change completely. Replace only:

- navigation labels and groups;
- record/entity names;
- page titles and descriptions;
- table columns and data renderers;
- metric labels and values;
- status definitions;
- validation schemas;
- API/query/mutation contracts;
- feature-specific panels and workflows.

Keep unchanged:

- shell geometry;
- page rhythm;
- typography scale;
- semantic token architecture;
- component dimensions;
- card/table/form density;
- drawer and modal structure;
- loading/empty/error states;
- interaction states;
- responsive prefixes and layout transitions;
- component reuse boundaries.

## 42. Universal UI Implementation Rules

Use this section as a system prompt for an AI coding assistant:

```text
Use this document as the visual and frontend architecture source of truth.

Build a business web application with the same compact operational UI language.
The business domain may change, but the visual language must remain consistent.

Use Next App Router, TypeScript, Tailwind CSS v4, shadcn/Radix primitives,
Lucide icons, TanStack Table, React Hook Form, Zod, TanStack Query, Zustand,
next-themes, and Sonner when those technologies match the project setup.

Use IBM Plex Sans for headings, Inter with Roboto fallback for body text, and
JetBrains Mono for technical values. Preserve the 48/32/24/20/16px heading scale,
14px body, 13px compact body, 12px caption, 11px overline, and 36px/28px metric
values with the specified weights, line heights, and tracking.

Preserve the shell: fixed 240px expanded sidebar, 64px collapsed sidebar, sticky
60px topbar, sidebar offsets matching those widths, and scrollable main content
with p-6. Use space-y-6/gap-6 for major page rhythm and the existing 4/8/12/16/
20/24/32/40/48/64px spacing scale.

Preserve the existing light/dark semantic palette and component dimensions. The
primary brand color may be replaced by a future application, but keep primary,
hover, soft, success, warning, danger, info, surface, border, text, radius,
shadow, and motion roles intact.

Use shadcn/Radix primitives. Do not create parallel Button, Input, Select, Dialog,
Sheet, Card, Table, Tabs, Badge, Dropdown, Tooltip, or form primitives. Compose
new feature components from those primitives and the shared DrawerForm, DataTable,
FormField, DetailHeader, EmptyState, StatusBadge, PageSkeleton, and toast helpers.

Use the established page templates: responsive page header plus space-y-6 content;
metric/dashboard grid; list page with toolbar/table/pagination/drawer; detail page
with DetailHeader/cards/tabs/related data; and form sections with RHF/Zod,
space-y-8 sections, space-y-2 fields, inline errors, and a drawer footer.

Use the existing table density: 40px header, 52px rows, px-4 cells, muted uppercase
header, alternating secondary surface rows, primary-soft hover, five skeleton rows,
search/filter/sort/visibility/pagination, and horizontal overflow.

Use the existing right-side DrawerForm: 400/560/720/900px max widths, z-50 black/20
overlay, surface header px-6 py-4, scrollable body px-6 py-6, footer px-6 py-4,
outline Cancel, primary submit, 200ms slide/fade, disabled loading action, preserved
failed input, and protection against accidental closure while Select/Popover is open.

Use the existing Dialog: centered max-md content, max-width calc(100%-2rem), p-6,
gap-6, rounded-none default, shadow-md, foreground ring, z-50 black/20 overlay,
100ms fade/zoom, and Radix focus/Escape behavior. Use AlertDialog for destructive
confirmation.

Preserve interaction states: tokenized hover, visible focus rings, active/selected
primary-soft treatment, disabled opacity without layout shift, loading spinners,
inline validation, retryable page errors, centered empty states, and deduplicated
Sonner success/error/info/warning feedback at top-right.

Preserve responsive behavior: stack page headers below sm, show breadcrumbs at sm,
use one-column forms below md and two-column forms at md, use multi-column dashboard
and detail grids at lg, hide the mobile menu button at lg, keep the fixed sidebar
behavior, and allow tables to scroll horizontally.

Do not introduce generic AI-generated SaaS aesthetics. Do not add gradients,
glassmorphism, decorative blobs, excessive whitespace, extra rounded card nesting,
new breakpoints, new colors, new animations, or new layout patterns unless the
existing source explicitly contains the pattern. Treat known radius, button casing,
input height, settings, authentication, direct-data, and document-view variations
as deliberate options and document any new deviation.

Keep the domain in feature data and copy. Keep the visual DNA, component behavior,
spacing, typography, density, layering, and architecture stable across CRM, ERP,
inventory, accounting, HR, procurement, logistics, healthcare administration,
e-commerce administration, and other internal business applications.
```

## 43. Final Neutrality and Fidelity Audit

- [x] This document does not require knowledge of the original business domain.
- [x] Product/domain-specific page names have been replaced with generic page, record, entity, metric, activity, and detail terminology.
- [x] Exact shell dimensions are preserved: `240px`, `64px`, `60px`.
- [x] Exact drawer widths are preserved: `400px`, `560px`, `720px`, `900px`.
- [x] Exact table dimensions are preserved: `40px` header and `52px` rows.
- [x] Exact form/input dimensions are preserved: `40px` shared input, `100px` textarea minimum, `44px` auth variation.
- [x] Exact colors and light/dark values are preserved.
- [x] Exact typography families, weights, sizes, line heights, and tracking are preserved.
- [x] Exact spacing tokens and repeated layout gaps are preserved.
- [x] Exact radius and shadow tokens are preserved, including known class-level variations.
- [x] Exact motion durations, easing, overlay opacity, and z-index values are preserved where source-backed.
- [x] Table, form, drawer, dialog, toast, loading, empty, error, and CRUD behavior are abstracted without domain assumptions.
- [x] Known inconsistencies are documented instead of normalized.
- [x] Unverified breakpoint pixel values, toast measurements, and some runtime metric details are explicitly marked as undetermined.
- [x] The result is intended to be reusable across unrelated business applications without changing the underlying UI architecture.
