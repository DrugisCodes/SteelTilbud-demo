import { Plus, Check } from "lucide-react";
import { Button } from "./ui/button";
import { Badge } from "./ui/badge";

export interface Product {
  id: string;
  name: string;
  category: string;
  store: string;
  price: number | string;
  originalPrice: number | string;
  discount: number | string;
  image: string;
  validUntil: string;
  mengde?: string;
  enhet?: string;
  pris_per_enhet?: number | string;
  pris_per_enhet_enhet?: string;
}

interface ProductCardProps {
  product: Product;
  isInList: boolean;
  onToggle: () => void;
}

const ProductCard = ({ product, isInList, onToggle }: ProductCardProps) => {
  // ---- Hjelpefunksjoner ----
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("no-NO", { day: "numeric", month: "short" });
  };

  const isFiniteNumber = (x: unknown): x is number =>
    typeof x === "number" && Number.isFinite(x);

  const formatPrice = (p: number | string | undefined) => {
    if (p === undefined || p === null) return "–";
    if (typeof p === "number") {
      if (!Number.isFinite(p)) return "–"; // unngå NaN
      return p.toLocaleString("no-NO", { minimumFractionDigits: 2 });
    }
    return p; // f.eks. "3 for 2" eller "−30%"
  };

  // Automatisk beregn rabatt kun hvis begge er tall
  let discount = 0;
  if (isFiniteNumber(product.price) && isFiniteNumber(product.originalPrice)) {
    if (product.originalPrice > product.price) {
      discount = Math.round(
        ((product.originalPrice - product.price) / product.originalPrice) * 100
      );
    }
  } else if (typeof product.discount === "number" && Number.isFinite(product.discount)) {
    discount = product.discount;
  }

  // Fallback tekst for ikke-numeriske tilbud (f.eks. "3 for 2")
  const discountText =
    typeof product.discount === "string" && product.discount.trim()
      ? product.discount.trim()
      : undefined;

  // Hva skal vises som «pris»-feltet?
  const displayPrice: string = isFiniteNumber(product.price)
    ? `${formatPrice(product.price)} kr`
    : typeof product.price === "string" && product.price.trim()
    ? product.price
    : discountText || "–";

  // ---- JSX ----
  return (
    <div className="group relative overflow-hidden rounded-xl bg-gradient-card border border-border shadow-soft hover:shadow-medium transition-all duration-300 hover:-translate-y-1">
      {/* Rabattmerke */}
      {(discount > 0 || discountText) && (
        <div className="absolute right-3 top-3 z-10">
          <Badge className="bg-[#ff944d] text-white font-semibold text-sm px-2 py-0.5 shadow-md rounded-full">
            {discount > 0 ? `-${discount}%` : discountText}
          </Badge>
        </div>
      )}

      {/* Innhold */}
      <div className="p-4 space-y-3">
        <div>
          <h3 className="font-semibold text-lg leading-tight mb-1 line-clamp-2">
            {product.name}
          </h3>
          <div className="flex items-center gap-2 text-sm text-muted-foreground">
            <span className="font-medium text-primary">{product.store}</span>
            <span>•</span>
            <span>{product.category}</span>
          </div>
        </div>

        <div className="flex items-end justify-between">
          <div>
            <div className="flex items-baseline gap-2">
              <span className="text-2xl font-bold text-foreground">{displayPrice}</span>

              {isFiniteNumber(product.originalPrice) &&
                isFiniteNumber(product.price) &&
                product.originalPrice > product.price && (
                  <span className="text-sm text-muted-foreground line-through opacity-80">
                    {formatPrice(product.originalPrice)} kr
                  </span>
                )}
            </div>


            {/* Mengde og pris per enhet */}
            <p className="text-xs text-muted-foreground mt-1">
              {product.mengde && product.enhet
                ? `${product.mengde}${product.enhet}`
                : ""}

              {product.pris_per_enhet && (
                <>
                  {" "}
                  •{" "}
                  {`${formatPrice(product.pris_per_enhet)}${
                    product.pris_per_enhet_enhet?.startsWith("kr")
                      ? ` ${product.pris_per_enhet_enhet}`
                      : ` kr/${product.pris_per_enhet_enhet || ""}`
                  }`}
                </>
              )}
            </p>
          </div>

          <Button
            onClick={onToggle}
            size="icon"
            variant={isInList ? "default" : "outline"}
            className={`h-10 w-10 rounded-lg transition-all ${
              isInList
                ? "bg-primary text-primary-foreground hover:bg-primary/90"
                : "hover:bg-primary/10 hover:border-primary"
            }`}
          >
            {isInList ? <Check className="h-5 w-5" /> : <Plus className="h-5 w-5" />}
          </Button>
        </div>
      </div>
    </div>
  );
};

export default ProductCard;
