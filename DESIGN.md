# DESIGN SYSTEM

## Bloomberg Terminal x Linear

---

## Core Philosophy

**Dense Information Architecture. Minimal Design Language.**

- Maximize data density without cognitive overload
- Monospace typography for clarity
- Systematic color coding for data classification
- Surgical use of whitespace to guide focus
- Zero decorative elements

---

## Theme Configuration

Two DaisyUI themes: `righteousfellowship` (light) and `righteousfellowship-dark` (dark).

### Color Tokens

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `primary` | #3b82f6 | #60a5fa | Links, primary actions, info highlights |
| `secondary` | #8b5cf6 | #a78bfa | Secondary actions |
| `accent` | #10b981 | #34d399 | Highlights |
| `success` | #10b981 | #34d399 | Positive states, affirmed doctrines, approved |
| `warning` | #fbbd23 | #fbbf24 | Pending, unclear, caution states |
| `error` | #ef4444 | #f87171 | Negative states, red flags, denied, avoid |
| `info` | #3abff8 | #3abff8 | Informational alerts |
| `base-100` | #ffffff | #0f172a | Primary background |
| `base-200` | #f3f4f6 | #1e293b | Secondary background |
| `base-300` | #e5e7eb | #334155 | Tertiary background |
| `base-content` | #1f2937 | #e2e8f0 | Primary text |

### Opacity Patterns

```
/{color}/10  - Subtle backgrounds (alerts, status boxes)
/{color}/20  - Badges, hover states, emphasis backgrounds
/{color}/30  - Borders, separators
/{color}/40  - Disabled states
/base-content/50  - Muted labels, tertiary text
/base-content/60  - Secondary labels, field labels
/base-content/70  - Secondary body text
/base-content/80  - Primary body text
```

---

## Typography

### Size Scale (Mobile -> Desktop)

| Class | Usage |
|-------|-------|
| `text-[8px]` | Micro labels, counters in tight spaces |
| `text-[9px]` / `sm:text-[10px]` | Sub-labels, hints, footnotes |
| `text-[10px]` / `sm:text-xs` | Standard body, field labels, badges |
| `text-xs` / `sm:text-sm` | Emphasized text, list items |
| `text-sm` / `sm:text-base` | Section headers, card titles |
| `text-base` / `sm:text-lg` | Page titles, key metrics |
| `text-lg` / `sm:text-xl` | Hero metrics, large numbers |
| `text-xl` / `sm:text-2xl` | Primary stat displays |

### Font Weight

- `font-bold` - Headers, labels, status indicators, emphasis
- `font-medium` - Secondary emphasis (rare)
- Default - Body text, descriptions

### Tabular Numbers

Use `tabular-nums` for any numeric data that may change or align:
```html
<span class="tabular-nums">85/100</span>
```

---

## Spacing

### Standard Padding

| Pattern | Usage |
|---------|-------|
| `p-2 sm:p-3` | Compact elements, list items, badges |
| `p-3 sm:p-4` | Standard cards, sections, alerts |
| `p-4 sm:p-6` | Large containers, hero sections |

### Margins & Gaps

| Pattern | Usage |
|---------|-------|
| `gap-1` / `gap-2` | Tight inline groupings |
| `gap-2` / `gap-3` | Standard spacing |
| `gap-3` / `gap-4` | Section separation |
| `space-y-2` | Vertical list stacks |
| `space-y-3` / `space-y-4` | Section content stacks |
| `space-y-px` | Pixel-separated list items (with bg-base-content/10 parent) |
| `mb-4 sm:mb-6` | Section bottom margins |

---

## Component Patterns

### Section Cards

Standard bordered container with header:

```html
<div class="border border-base-content/20">
  <div class="bg-base-content/5 p-3 border-b border-base-content/20">
    <div class="text-[10px] sm:text-xs font-bold">SECTION TITLE</div>
  </div>
  <div class="p-3 sm:p-4">
    <!-- Content -->
  </div>
</div>
```

With status coloring:
```html
<div class="border border-success/30">
  <div class="bg-success/10 p-3 border-b border-success/30">
    <div class="text-[10px] sm:text-xs font-bold text-success">SUCCESS SECTION</div>
  </div>
  <div class="p-3">...</div>
</div>
```

### Status Alerts

```html
<!-- Success -->
<div class="bg-success/10 border border-success/30 p-3 sm:p-4">
  <div class="text-[10px] sm:text-xs text-success font-bold mb-2">SUCCESS TITLE</div>
  <div class="text-[10px] sm:text-xs text-base-content/80">Message content</div>
</div>

<!-- Warning -->
<div class="bg-warning/10 border border-warning/30 p-3 sm:p-4">...</div>

<!-- Error -->
<div class="bg-error/10 border border-error/30 p-3 sm:p-4">...</div>

<!-- Info -->
<div class="bg-info/10 border border-info/30 p-3 sm:p-4">...</div>

<!-- Neutral -->
<div class="bg-base-content/5 border border-base-content/20 p-3 sm:p-4">...</div>
```

### Status Badges

```html
<span class="bg-success/20 text-success px-2 py-1 text-[10px] font-bold">APPROVED</span>
<span class="bg-warning/20 text-warning px-2 py-1 text-[10px] font-bold">PENDING</span>
<span class="bg-error/20 text-error px-2 py-1 text-[10px] font-bold">REJECTED</span>
<span class="bg-info/20 text-info px-2 py-1 text-[10px] font-bold">REVIEW</span>
```

### Expandable Details

```html
<details class="border border-base-content/10">
  <summary class="cursor-pointer p-3 font-bold text-[10px] sm:text-xs hover:bg-base-content/5 transition-colors">
    EXPANDABLE SECTION TITLE
  </summary>
  <div class="p-3 border-t border-base-content/10 text-[10px] sm:text-xs">
    Expanded content here
  </div>
</details>
```

---

## Data Display

### Key-Value Pairs

```html
<div>
  <dt class="text-[10px] text-base-content/60 mb-1">LABEL</dt>
  <dd class="text-xs font-bold">Value</dd>
</div>
```

### Doctrine/Boolean Items

Affirmed (positive):
```html
<div class="flex items-center gap-2">
  <span class="text-success">+</span>
  <span class="text-base-content">Doctrine Name</span>
</div>
```

Denied (negative):
```html
<div class="flex items-center gap-2">
  <span class="text-error">-</span>
  <span class="text-error">Doctrine Name (DENIED)</span>
</div>
```

Unclear/Unknown:
```html
<div class="flex items-center gap-2">
  <span class="text-base-content/40">?</span>
  <span class="text-base-content/60">Doctrine Name</span>
</div>
```

Yes/No Display (shared/_doctrine_item.html.erb pattern):
```html
<div class="bg-base-100 p-2 sm:p-3 flex items-center justify-between">
  <span class="text-[10px] sm:text-xs font-medium">LABEL</span>
  <!-- If true -->
  <span class="text-success font-bold text-[10px] sm:text-xs">YES</span>
  <!-- If false -->
  <span class="text-error font-bold text-[10px] sm:text-xs">NO</span>
</div>
```

### Metric Displays

Single metric:
```html
<div class="text-center">
  <div class="text-xl sm:text-2xl font-bold text-success tabular-nums">42</div>
  <div class="text-[8px] sm:text-[9px] text-base-content/50">LABEL</div>
</div>
```

### Rating/Progress Bars

```html
<div class="h-1.5 bg-base-content/10 overflow-hidden">
  <div class="h-full bg-success" style="width: 75%"></div>
</div>
```

With label:
```html
<div>
  <div class="flex justify-between items-center mb-1">
    <span class="text-[9px] text-base-content/60">METRIC NAME</span>
    <span class="text-[9px] font-bold text-success">75%</span>
  </div>
  <div class="h-1.5 bg-base-content/10 overflow-hidden">
    <div class="h-full bg-success" style="width: 75%"></div>
  </div>
</div>
```

---

## Grid Layouts

### Quick Stats Grid

4-column responsive grid with colored left borders:
```html
<div class="grid grid-cols-2 sm:grid-cols-4 gap-px bg-base-content/10 border border-base-content/10">
  <div class="bg-base-100 p-3 border-l-2 border-success">
    <div class="text-[10px] sm:text-xs text-base-content/60 mb-1">LABEL</div>
    <div class="text-xl sm:text-2xl font-bold text-success">VALUE</div>
    <div class="text-[10px] sm:text-xs text-base-content/50">SUBLABEL</div>
  </div>
  <!-- More cells... -->
</div>
```

### Two-Column Balance

```html
<div class="grid grid-cols-2 gap-3">
  <div class="text-center p-3 border border-success/30 bg-success/5">
    <div class="text-[9px] text-base-content/60 mb-1">LEFT METRIC</div>
    <div class="text-xl font-bold text-success">85</div>
  </div>
  <div class="text-center p-3 border border-base-content/20">
    <div class="text-[9px] text-base-content/60 mb-1">RIGHT METRIC</div>
    <div class="text-xl font-bold">72</div>
  </div>
</div>
```

### Main + Sidebar Layout

```html
<div class="grid grid-cols-1 lg:grid-cols-3 gap-4 sm:gap-6">
  <div class="lg:col-span-2 space-y-4 sm:space-y-6">
    <!-- Main content sections -->
  </div>
  <div class="space-y-4 sm:space-y-6">
    <!-- Sidebar sections -->
  </div>
</div>
```

---

## Interactive Elements

### Buttons

Primary action:
```html
<button class="bg-primary text-primary-content hover:bg-primary/80 px-4 py-2 text-[10px] sm:text-xs font-bold transition-colors">
  PRIMARY ACTION
</button>
```

Success action:
```html
<button class="bg-success text-success-content hover:bg-success/80 px-4 py-2 text-[10px] sm:text-xs font-bold transition-colors">
  APPROVE
</button>
```

Danger action:
```html
<button class="bg-error text-error-content hover:bg-error/80 px-4 py-2 text-[10px] sm:text-xs font-bold transition-colors">
  DELETE
</button>
```

Ghost/Outline:
```html
<button class="bg-primary/10 hover:bg-primary/20 border border-primary/30 px-3 py-2 text-[10px] sm:text-xs font-bold transition-colors">
  SECONDARY ACTION
</button>
```

Block button:
```html
<a class="block w-full text-center bg-primary/10 hover:bg-primary/20 border border-primary/30 px-3 py-3 text-[10px] sm:text-xs font-bold transition-colors touch-manipulation">
  FULL WIDTH ACTION
</a>
```

### Links

```html
<a class="text-primary hover:underline">Link Text</a>
<a class="text-primary hover:underline font-bold">VIEW ALL -></a>
```

### Touch Targets

Add `touch-manipulation` to interactive elements for better mobile performance:
```html
<button class="... touch-manipulation">
```

---

## List Patterns

### Pixel-Separated List

```html
<div class="space-y-px bg-base-content/10 border border-base-content/10">
  <div class="bg-base-100 p-3 hover:bg-base-200 transition-colors">
    Item 1
  </div>
  <div class="bg-base-100 p-3 hover:bg-base-200 transition-colors">
    Item 2
  </div>
</div>
```

### Church/Entity List Item

```html
<div class="bg-base-100 p-3 hover:bg-base-200 transition-colors touch-manipulation">
  <div class="flex justify-between items-start gap-3">
    <div class="flex-1">
      <a class="font-bold hover:underline text-xs sm:text-sm">
        ENTITY NAME
      </a>
      <div class="text-[10px] sm:text-xs text-base-content/60 mt-1">
        Subtitle or address
      </div>
    </div>
    <span class="text-[10px] sm:text-xs font-bold tabular-nums text-success">
      85/100
    </span>
  </div>
</div>
```

---

## Breadcrumbs

```html
<div class="text-[10px] sm:text-xs text-base-content/60 mb-4">
  <a href="#" class="hover:underline">PARENT</a> / CURRENT PAGE
</div>
```

---

## Conditional Styling

### Rating-Based Colors

```erb
<%= class_for_rating(value) %>

<%# Helper: %>
def class_for_rating(value)
  return 'text-base-content/50' if value.nil?
  return 'text-success' if value >= 70
  return 'text-warning' if value >= 40
  'text-error'
end
```

Pattern:
```html
<span class="<%= value >= 70 ? 'text-success' : value >= 40 ? 'text-warning' : 'text-error' %>">
```

### Boolean Status Colors

```html
<!-- Success when true, Error when false -->
<div class="<%= condition ? 'border-success/30 bg-success/10' : 'border-error/30 bg-error/10' %>">

<!-- With border accent -->
<div class="border-l-2 <%= condition ? 'border-success' : 'border-error' %>">
```

---

## Icons

Use Phosphor Icons (ph class prefix):
```html
<i class="ph ph-book-open"></i>
<i class="ph ph-check-circle"></i>
<i class="ph ph-warning-circle"></i>
<i class="ph ph-church"></i>
```

Icons inline with text:
```html
<div class="flex items-center gap-2">
  <i class="ph ph-check-circle"></i>
  Label Text
</div>
```

---

## Responsive Breakpoints

- Default: Mobile-first (< 640px)
- `sm:` - 640px+ (tablet/desktop)
- `lg:` - 1024px+ (large screens, sidebar layouts)

Common patterns:
```
text-[10px] sm:text-xs      - Typography scaling
p-3 sm:p-4                  - Padding scaling
grid-cols-2 sm:grid-cols-4  - Grid column scaling
gap-4 sm:gap-6              - Gap scaling
```

---

## Anti-Patterns (Avoid)

- Rounded corners (`rounded-*`) - Use sharp edges
- Shadows (`shadow-*`) - Use borders instead
- Gradients - Use flat colors
- Large padding - Keep dense
- Decorative icons - Use functional icons only
- Excessive whitespace - Maximize information density

