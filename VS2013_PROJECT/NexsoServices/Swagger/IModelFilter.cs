using System;

namespace Swagger.Net
{
    public interface IModelFilter
    {
        void Apply(DataType model, DataTypeRegistry dataTypeRegistry, Type type);
    }
}