package kg.ash.javavi.clazz;

import java.util.LinkedList;
import java.util.List;
import java.util.Objects;

public class ClassConstructor {
    
    private String declaration = "";
    private int modifiers;
    private List<ClassTypeParameter> typeParameters 
        = new LinkedList<>();

    public void setDeclaration(String declaration) {
        this.declaration = declaration;
    }

    public String getDeclaration() {
        return declaration;
    }

    public void setModifiers(int modifiers) {
        this.modifiers = modifiers;
    }

    public int getModifiers() {
        return modifiers;
    }

    public void addTypeParameter(ClassTypeParameter parameter) {
        typeParameters.add(parameter);
    }

    public List<ClassTypeParameter> getTypeParameters() {
        return typeParameters;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final ClassConstructor other = (ClassConstructor) obj;
        if (!Objects.equals(this.declaration, other.declaration) && (this.declaration == null || !this.declaration.equals(other.declaration))) {
            return false;
        }
        return this.modifiers == other.modifiers;
    }

    @Override
    public int hashCode() {
        int hash = 7;
        hash = 17 * hash + (new Integer(modifiers).hashCode());
        hash = 17 * hash + (this.declaration != null ? this.declaration.hashCode() : 0);
        return hash;
    }

}
