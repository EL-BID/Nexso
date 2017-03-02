﻿using System;
using System.Collections.Generic;
using System.Linq;

namespace Swagger.Net
{
    public static class TypeExtensions
    {
        public static bool IsNullable(this Type type, out Type nullableTypeArgument)
        {
            nullableTypeArgument = null;

            if (type.IsGenericType && type.GetGenericTypeDefinition() == typeof (Nullable<>))
            {
                nullableTypeArgument = type.GetGenericArguments().Single();
                return true;
            }

            return false;
        }

        public static bool IsEnumerable(this Type type, out Type enumerableTypeArgument)
        {
            enumerableTypeArgument = null;
            var enumerableType = type.GetInterfaces()
                .Union(new[] {type})
                .FirstOrDefault(
                    intfc => intfc.IsGenericType && intfc.GetGenericTypeDefinition() == typeof (IEnumerable<>));

            if (enumerableType != null)
                enumerableTypeArgument = enumerableType.GetGenericArguments().First();

            return enumerableType != null;
        }

        public static bool IsEnumerable(this Type type)
        {
            Type enumerableTypeArgument;
            return IsEnumerable(type, out enumerableTypeArgument);
        }
    }
}