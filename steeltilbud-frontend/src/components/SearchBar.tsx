import { Search, RefreshCw } from "lucide-react";
import { Input } from "./ui/input";
import { Button } from "./ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "./ui/select";

interface SearchBarProps {
  searchTerm: string;
  onSearchChange: (value: string) => void;
  selectedStore: string;
  onStoreChange: (value: string) => void;
  selectedCategory: string;
  onCategoryChange: (value: string) => void;
  onRefresh: () => void;
}

const stores = ["Alle butikker", "Kiwi", "Rema 1000", "Coop Extra", "Bunnpris", "Spar", "Meny"];
const categories = [
  "Alle kategorier",
  "Meieri",
  "Frukt og grønt",
  "Kjøtt",
  "Fisk",
  "Frossenmat",
  "Bakst",
  "Tørrvarer",
  "Drikke",
  "Husholdning",
  "Pålegg",
  "Hygiene",
  "Snacks",
  "Annet",
];

const SearchBar = ({
  searchTerm,
  onSearchChange,
  selectedStore,
  onStoreChange,
  selectedCategory,
  onCategoryChange,
  onRefresh,
}: SearchBarProps) => {
  return (
    <div className="space-y-4">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-muted-foreground" />
        <Input
          type="text"
          placeholder="Søk etter produkter..."
          value={searchTerm}
          onChange={(e) => onSearchChange(e.target.value)}
          className="pl-10 h-12 bg-card border-border focus:border-primary shadow-soft"
        />
      </div>
      
      <div className="flex flex-col sm:flex-row gap-3">
        <Select value={selectedStore} onValueChange={onStoreChange}>
          <SelectTrigger className="h-11 bg-card border-border shadow-soft">
            <SelectValue placeholder="Velg butikk" />
          </SelectTrigger>
          <SelectContent className="bg-popover border-border">
            {stores.map((store) => (
              <SelectItem key={store} value={store}>
                {store}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        <Select value={selectedCategory} onValueChange={onCategoryChange}>
          <SelectTrigger className="h-11 bg-card border-border shadow-soft">
            <SelectValue placeholder="Velg kategori" />
          </SelectTrigger>
          <SelectContent className="bg-popover border-border">
            {categories.map((category) => (
              <SelectItem key={category} value={category}>
                {category}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>

        <Button
          onClick={onRefresh}
          variant="outline"
          className="h-11 gap-2 bg-primary text-primary-foreground hover:bg-primary/90 border-0 shadow-soft"
        >
          <RefreshCw className="h-4 w-4" />
          Oppdater tilbud
        </Button>
      </div>
    </div>
  );
};

export default SearchBar;
